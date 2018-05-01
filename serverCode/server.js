var apn = require('apn')
var apnProvider = new apn.Provider({  
     token: {
        key: 'AuthKey_7FYVT9ADUV.p8', // Path to the key p8 file
        keyId: '7FYVT9ADUV', // The Key ID of the p8 file (available at https://developer.apple.com/account/ios/certificate/key)
        teamId: '56W2NPXKTS'
    },
    production: false
});

var models = require('./models')
var express = require('express')
var app = express()
var bodyParser = require('body-parser')
var config = require('./dev-config')
var bcrypt = require('bcrypt')
var jwt = require('jsonwebtoken')



app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json({limit: '50mb'}))


var server = require('http').createServer(app)


app.use(function (req, res, next) {
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Headers', 'Origin, Accept, Accept-Version, Content-Length, Content-MD5, Content-Type, Date, X-Api-Version, X-Response-Time, X-PINGOTHER, X-CSRF-Token, authorization');
    res.header('Access-Control-Allow-Methods', '*');
    res.header('Access-Control-Expose-Headers', 'X-Api-Version, X-Request-Id, X-Response-Time, authorization');
    res.header('Access-Control-Max-Age', '1000');
    res.header('Access-Control-Allow-Methods', 'GET, PUT, POST, DELETE, OPTIONS');
    next();
});


//PUBLIC

function sendNotificationIOS(message, pushNotificationKey) {
	console.log("SEnding notification")
	console.log("Message: "+message)
	console.log("key: "+pushNotificationKey)
	var notification = new apn.Notification();
	notification.topic = 'southpawac.Laundry2';
	notification.expiry = Math.floor(Date.now() / 1000) + 3600;
	notification.badge = 1;
	notification.sound = 'default';
	notification.alert = message;
	notification.payload = {id: 123};
	return apnProvider.send(notification, pushNotificationKey).then(function(response) {
		console.log(response)
		return {success: true}
	}).catch(function(err){
		console.log("ERROR")
		console.log(err)
		return {success: true}
	})
}


app.post('/authenticate', function(req, res) {
	models.User.findOne({
		where: { 
			$or: [
					{
						email: req.body.email.toLowerCase()
					}
				]
			}
		}).then(function(user) {
			if (user != null) {
				bcrypt.compare(req.body.password, user.password, function(err, res2) {
					if (res2 == true) {
						models.User.update({pushNotificationId: req.body.pushNotificationKey}, {where: {id: user.id}}).then(function(u) {
							var token = jwt.sign({user_info: user}, config.jwtSecret);
							res.json({success: true, token: token, name: user.name, email: user.email, id: user.id})
						})
					} else {
						res.json({success: false})
					}
				});
			} else {
				res.send({success: false})
			}
	}).catch(function(er) {
		res.send({success: false})
	})
})



app.post("/setup_account", function(req, res) {
	models.User.findOne({where: {
			email: req.body.email
		}}).then(function(user) {
		if (user) {
			res.send({success: false, message: "A user with this email already exists."});
		} else {
			bcrypt.genSalt(10, function(err, salt) {
				bcrypt.hash(req.body.password, salt, function(err, hash) {
					models.User.create({name: req.body.name, email: req.body.email, pushNotificationId: req.body.pushNotificationKey, password: hash}).then(function(user) {
						if (user) {
							var token = jwt.sign({user_info: {id: user.id}}, config.jwtSecret);
							res.send({
								success: true,
								name: user.name,
								id: user.id,
								email: user.email,
								token: token
							});
						} else {
							res.send({success: false, message: "Was not able to create account."})
						}
					})
				});
			});
		}
	})
});



app.get("/", function(req, res) {
	console.log("here")
	res.send({success: false})
})


app.post("/endSession", function(req, res) {
	console.log("Ending session")
	var end = Date.now();
	models.Session.findOne({where: {machineId: req.body.machineId}}).then(function(session) {
		if(session != null){
			models.User.findOne({where: {id: session.userId}}).then(function(to) {
				models.Session.update({end: end},{where: {id: session.id}}).then(function(u) {
					sendNotificationIOS("Your laundry has finished", to.pushNotificationId).then(function(result) {
						res.send(result)
					});
				});
			});
		} else {
			console.log("No open session")
			res.send({success: false, message: "No open session"})
		}
	})
})

//AUTH

app.use(function(req, res, next) {

	// check header or url parameters or post parameters for token
	if ('OPTIONS' == req.method) {
		res.sendStatus(204);
	} else {
		var token = req.headers['authorization'];
		if (token) {
			// verifies secret and checks exp
			jwt.verify(token, config.jwtSecret, function(err, decoded) {      
				if (err) {
					return res.json({ success: false, message: 'Failed to authenticate token.' });    
				} else {
					// if everything is good, save to request for use in other routes
					req.decoded = decoded;  
					next();
				}
			});
		} else {
			return res.status(403).send({ 
				success: false, 
				message: 'No token provided.' 
			});
		}
	}
});




app.post("/messageUser", function(req, res) {
	models.User.findOne({where: {id: req.body.to}}).then(function(to) {
		models.User.findOne({where: {id: req.decoded.user_info.id}}).then(function(mfrom) {
			sendNotificationIOS(mfrom.name+": "+req.body.message, to.pushNotificationId).then(function(result) {
				res.send(result)
			})
		})
	})
})


app.post("/emptySession", function(req, res) {
	var end = Date.now();
	models.User.findOne({where: {id: req.body.to}}).then(function(to) {
		models.Session.update({end: end}, {where: {machineId: req.body.machineId}}).then(function(u) {
			sendNotificationIOS("Your laundry has been emptied", to.pushNotificationId).then(function(result) {
				res.send(result)
			});
		});
	});
})

app.post("/getMachineStatus", function(req, res) {
	models.Session.findOne({where: {machineId: req.body.machineId, end:  null}}).then(function(active) {
		if (active == null) {
			res.send({success: true, status: "empty"})
		} else {
			models.User.findOne({where: {id: active.userId}}).then(function(person) {
				res.send({success: true, status: "full", user: person})
			})
		}
	})
})

//PRIVATE
app.post("/requestSession", function(req, res) {
	var start = Date.now();
	models.Session.create({start: start, machineId:req.body.machineId, userId: req.decoded.user_info.id}).then(function(session) {
		res.send({success: true})
	}).catch(function(err) {
		res.send({success: false})
	})
})

models.sequelize.sync().then(function () {
    server.listen(config.port);
    console.log('app is running on port ' + config.port);
});



