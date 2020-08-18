const functions = require('firebase-functions')
const admin = require('firebase-admin')
const { v4: uuidv4 } = require('uuid')
admin.initializeApp(functions.config().firebase)

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
exports.helloWorld = functions.https.onRequest((request, response) => {
  response.send(`return ${functions.config().someservice.key}`)
})

exports.processSignUp = functions.auth.user().onCreate((user) => {
  const customClaims = {
    'https://hasura.io/jwt/claims': {
      'x-hasura-default-role': 'user',
      'x-hasura-allowed-roles': ['user'],
      'x-hasura-user-id': uuidv4(), // user.uid,
    },
  }

  return (
    admin
      .auth()
      .setCustomUserClaims(user.uid, customClaims)
      // .then(() => {
      //   // Update real-time database to notify client to force refresh.
      //   const metadataRef = admin.database().ref('metadata/' + user.uid)
      //   // Set the refresh time to the current UTC timestamp.
      //   // This will be captured on the client to force a token refresh.
      //   return metadataRef.set({ refreshTime: new Date().getTime() })
      // })
      .catch((error) => {
        console.log(error)
      })
  )
})
