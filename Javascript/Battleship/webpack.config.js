const path = require("path");
const HtmlWebpackPlugin = require("html-webpack-plugin");

module.exports = {
  mode: "development",
  entry: "./src/index.js",
  output: {
    filename: "bundle.js",
    path: path.resolve(__dirname, "dist"),
    clean: true,
  },
  devtool: "eval-source-map",
  devServer: {
    static: "./dist",
    watchFiles: ["./src/template.html"],
    hot: true,
  },
  plugins: [
    new HtmlWebpackPlugin({
      template: "./src/template.html",
      title: "Battleship | The Odin Project",
    }),
  ],
  module: {
    rules: [
      {
        test: /\.css$/i,
        use: ["style-loader", "css-loader"],
      },
      {
        test: /\.(png|svg|jpg|jpeg|gif|mp3|wav)$/i,
        type: "asset/resource",
      },
    ],
  },
};
