var etx = require("extract-text-webpack-plugin");
var webpack = require("webpack");

module.exports = {
  context: __dirname + "/app",
  entry: {
    app: "./index.coffee"
  },
  output: {
    path: __dirname + "/dist",
    filename: "[name].js"
  },
  module: {
    loaders: [
      { test: /\.coffee$/, loader: "coffee-loader" }
    ]
  },
  devServer: {
    headers: { "Access-Control-Allow-Origin": "http://127.0.0.1:8888" , "Access-Control-Allow-Credentials": "true"}
  },
  plugins: [
    new etx("app.css", {}),
    new webpack.DefinePlugin({
      BASEURL: JSON.stringify(process.env.BASEURL)
    })
  ],
  resolve: { extensions: ["", ".webpack.js", ".web.js", ".js", ".coffee", ".less", ".html"]}
};
