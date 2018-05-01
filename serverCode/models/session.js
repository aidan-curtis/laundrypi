'use strict';
module.exports = function(sequelize, DataTypes) {
  var Session = sequelize.define('Session', {
      id: {type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true, unique: true},
      machineId: {type: DataTypes.STRING},
      start: {type: DataTypes.STRING},
      end: {type: DataTypes.STRING}
  }, {
    classMethods: {
      associate: function(models) {
        // associations can be defined here

      }
    }
  });
  return Session;
};