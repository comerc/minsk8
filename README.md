# minsk8

Flutter в режиме live-code

## How to start

```
$ flutter packages pub run build_runner build
```

for VSCode Apollo GraphQL

```
$ npm install -g apollo
```

create `./apollo.config.js`

```js
module.exports = {
  client: {
    includes: ['./lib/**/*.dart'],
    service: {
      name: 'minsk8',
      url: 'https://minsk8.herokuapp.com/v1/graphql',
      // optional headers
      headers: {
        'x-hasura-admin-secret': '<secret>',
        'x-hasura-role': 'user',
      },
      // optional disable SSL validation check
      skipSSLValidation: true,
      // alternative way
      // localSchemaFile: './schema.json',
    },
  },
}
```

how to download `schema.json` for `localSchemaFile`

```
$ apollo schema:download --endpoint https://minsk8.herokuapp.com/v1/graphql --header 'X-Hasura-Admin-Secret: <secret>' --header 'X-Hasura-Role: user'
```
