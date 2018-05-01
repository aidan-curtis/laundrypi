'use strict';
module.exports = function(sequelize, DataTypes) {
  var User = sequelize.define('User', {
      id: {type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true, unique: true},
      name: {type: DataTypes.STRING},
      password: {type: DataTypes.STRING},
      email: {type: DataTypes.STRING},
      pushNotificationId: {type: DataTypes.STRING},
      token: {type: DataTypes.STRING}
  }, {
    classMethods: {
      associate: function(models) {
        // associations can be defined here
      }
    }
  });
  return User;
};