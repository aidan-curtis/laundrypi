var fs = require("fs");
var path = require("path");
var Sequelize= require("sequelize");
var config= require('../dev-config');

var db = {};
console.log(config)
var sequelize = new Sequelize(config.db.schema, config.db.user, config.db.password, config.opts);
fs
  .readdirSync(__dirname)
  .filter(function(file) {
    return (file.indexOf(".") !== 0) && (file !== "index.js");
  })
  .forEach(function(file) {
    var model = sequelize.import(path.join(__dirname, file));
    db[model.name] = model;
  });
Object.keys(db).forEach(function(modelName) {
  if ("associate" in db[modelName]) {
    db[modelName].associate(db);
  }
});


db.User.hasMany(db.Session, {foreignKey: "userId"});


db.sequelize = sequelize;


module.exports = db;