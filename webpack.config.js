const webpack = require('webpack');
const autoprefixer = require('autoprefixer')
const ExtractTextPlugin = require('extract-text-webpack-plugin')
const path = require('path')
const Clean = require('clean-webpack-plugin');


module.exports = {
  entry: {
    main: ['./source/javascripts/main']
  },

  resolve: {
    root: __dirname + '/source/javascripts',
  },

  module: {
    loaders: [
      {
        test: /source\/javascripts\/.*\.js$/,
        exclude: /node_modules|\.tmp|vendor/,
        loader: 'babel-loader',
        query: {
          presets: ['es2015', 'stage-0']
        },
      },
      {
        test: /\.scss$/,
        loader: ExtractTextPlugin.extract('style-loader', [
          'css-loader',
          'postcss-loader',
          'sass-loader?indentedSyntax=scss&includePaths[]=' + path.resolve(__dirname, './source/stylesheets')
        ].join('!'))
      }
    ],
  },

  plugins: [
    new Clean(['.tmp']),
    new webpack.ProvidePlugin({
      $: 'jquery',
      jQuery: 'jquery',
      'window.jQuery': 'jquery'
    }),
    new ExtractTextPlugin('stylesheets/[name].css')
  ],

  postcss: [
    autoprefixer({
      browsers: ['last 2 versions']
    })
  ],

  output: {
    path: __dirname + '/.tmp/dist',
    filename: 'javascripts/[name].js',
  },

  resolve: {
    extensions: ['', '.js', '.scss'],
    root: [path.join(__dirname, './source')]
  }
};
