const functions = require('firebase-functions')
const https = require('https')
const sharp = require('sharp')

// Convert option in a string format to a key-value pair
// key=value   { [key]: value }
// key         { [key]: true }
const optionToKeyVal = (option/*: string*/) =>
  ((split/*: string[]*/) =>
    split.length > 0
      ? { [split[0]]: split.length > 1 ? split[1] : true }
      : undefined)(option.split('='))

// Parse options string and return options object
const parseOptions = (
  options/*: string*/
) =>
  options
    .split(',')
    .reduce((acc, option) => ({ ...acc, ...optionToKeyVal(option) }), {})
/*: {
  width?: string;
  height?: string;
  lossless?: boolean;
}*/

// Configure allowed request URLs. This should match the hosting glob pattern
const allowedPrefix = '/cdn/image/'
const isUrlAllowed = (url/*: string*/) => url.startsWith(allowedPrefix)

// Configure source image URLs. This assumes that we store images on Firebase Storage
const projectId = 'minsk8-2' // process.env.GCLOUD_PROJECT
const sourcePrefix = `https://firebasestorage.googleapis.com/v0/b/${projectId}.appspot.com/o/`
const sourceSuffix = '?alt=media'

// Validate and split request URL into options and source parts
const tokenizeUrl = (url/*: string*/) => {
  if (!isUrlAllowed(url)) {
    throw new Error('URL is not allowed')
  }
  const urlNoPrefix = url.slice(allowedPrefix.length)
  const optionsSlashIdx = urlNoPrefix.indexOf('/')
  const sourceKey = urlNoPrefix.slice(optionsSlashIdx + 1)
  const optionsStr = urlNoPrefix.slice(0, optionsSlashIdx)
  const sourceUrl = sourcePrefix + sourceKey + sourceSuffix
  return [optionsStr, sourceUrl]
}

// Set CDN caching duration in seconds
const cacheMaxAge = 60 * 60 * 24 * 100 // 100 days (60 seconds x 60 minutes x 24 hours x 100 days)

// Run the image transformation on Http requests.
// To modify memory and CPU allowance use .runWith({...}) method
exports.imageTransform = functions.https.onRequest((request, response) => {
  try {
    const [optionsStr, sourceUrlStr] = tokenizeUrl(request.url)
    const sourceUrl = new URL(sourceUrlStr)
    const options = parseOptions(optionsStr)

    // Modern browsers that support WebP format will send an appropriate Accept header
    const acceptHeader = request.header('Accept')
    const webpAccepted =
      !!acceptHeader && acceptHeader.indexOf('image/webp') !== -1

    // If one of the dimensions is undefined the automatic sizing
    // preserving the aspect ratio will be applied
    const transform = sharp()
      .resize(
        options.width ? Number.parseInt(options.width, 10) : null,
        options.height ? Number.parseInt(options.height, 10) : null,
        {
          fit: 'cover'
        }
      )
      .webp({ force: webpAccepted, lossless: !!options.lossless })

    // Set cache control headers. This lets Firebase Hosting CDN to cache
    // the converted image and serve it from cache on subsequent requests.
    // We need to Vary on Accept header to correctly handle WebP support detection.
    const responsePipe = response
      .set('Cache-Control', `public, max-age=${cacheMaxAge}`)
      .set('Vary', 'Accept')

    https.get(sourceUrl, res => res.pipe(transform).pipe(responsePipe))
  } catch (error) {
    functions.logger.log(`error: ${error}`)
    response.status(400).send()
    return
  }
})