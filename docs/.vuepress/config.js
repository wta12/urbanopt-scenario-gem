const path = require('path');

module.exports = {
  base: '/urbanopt-scenario-gem/',
  themeConfig: {
    navbar: false,
    sidebar: [
      "/"
    ]
  },
  chainWebpack: config => {
    config.module
      .rule('json')
        .test(/\.json$/)
        .use(path.join(__dirname, 'json-schema-deref-loader.js'))
          .loader(path.join(__dirname, 'json-schema-deref-loader.js'))
          .end()
  },
};