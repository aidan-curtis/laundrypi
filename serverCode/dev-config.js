
var config = {}

var db = {};
db.user = "laundry";
db.password = "Ludy*7481";
db.schema = "laundry";

var opts = {
    host: "laundry.c89pfy7v9e7u.us-east-1.rds.amazonaws.com",
    dialect: "mysql",
    pool: {
    max: 5,
    min: 0,
    idle: 10000
  },
  dialectOptions: {
    encrypt: true
  }
};



config.db = db;
config.opts = opts;
config.port = 8000

config.jwtSecret = "12awefahsdifadshkj"

module.exports = config;