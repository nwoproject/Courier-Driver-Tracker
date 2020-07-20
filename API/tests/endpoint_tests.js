const app = require('../core/app');
const chai = require('chai');
const chaiHttp = require('chai-http')
const { expect }  = chai;

/* Sensitive data that is used for testing purposes */
const EMAIL_MANAGER = process.env.EMAIL_TEST_M;
const EMAIL_DRIVER = process.env.EMAIL_TEST_D;
const PASSWORD_MANAGER = process.env.PASSWORD_TEST_M;
const PASSWORD_DRIVER = process.env.PASSWORD_TEST_D;
const TOKEN_DRIVER = process.env.TOKEN_TEST_D;

/* User Athentication Test data */
const successManagerAuth = {
    email: EMAIL_MANAGER,
    password: PASSWORD_MANAGER
}

const failManagerAuth = {
    email: EMAIL_MANAGER,
    password: 'wrongpassword'
}

const invalidManagerAuth = {
    email: 'nonexistantemail@notadomain.com',
    password: 'wrongpassword'
}

const managerAuthResponse= {
    'id': 5,
}

const successDriverAuth = {
    email: EMAIL_DRIVER,
    password: PASSWORD_DRIVER
}

const failDriverAuth = {
    email: EMAIL_DRIVER,
    password: 'wrongpassword'
}

const notFoundDriverAuth = {
    email: 'nonexistantemail@notadomain.com',
    password: 'wrongpassword'
}

const driverAuthResponse= {
    'id': '16',
}

const updateDriverPassword = {
    password: PASSWORD_DRIVER,
    token: TOKEN_DRIVER
}

const invalidupdateDriverPassword = {
    password: PASSWORD_DRIVER,
    token: 'invalidtoken'
}

/* Location Test data */

const setDriverLocation = {
    'token': TOKEN_DRIVER,
    'latitude': '-25.7542559',
    'longitude': '28.2321043'
}

const responseGetLocation = {
    'drivers': [
        {
            'id': '16',
            'name': 'DoNotDelete',
            'surname': 'DoNotDelete',
            'latitude': '-25.7542559',
            'longitude': '28.2321043'
        }
    ]
}

/* unit tests */

chai.use(chaiHttp);
describe('Server', ()=>{
    describe('Bearer token check',()=>{
        it('Missing Authorization header or invalid bearer token',done =>{
            chai
            .request(app)
            .get('/api')
            .send()
            .end((err,res)=>{
                expect(res).to.have.status(401);
                done();
            }).timeout(5000);
        });
    });
    describe('Authenticating manager', ()=>{
        it('Manager is valid', done =>{
            chai
                .request(app)
                .post('/api/managers/authenticate')
                .set('Authorization', 'Bearer ' + process.env.BEARER_TOKEN)
                .send(successManagerAuth)
                .end((err,res)=>{
                    expect(res).to.have.status(200);
                    expect(res).to.be.json;
                    expect(res.body.id).to.equals(managerAuthResponse.id);
                    done();
                }).timeout(5000);
        });
        it('Manager not valid (Account exists but incorrect password)', done =>{
            chai
                .request(app)
                .post('/api/managers/authenticate')
                .set('Authorization', 'Bearer ' + process.env.BEARER_TOKEN)
                .send(failManagerAuth)
                .end((err,res)=>{
                    expect(res).to.have.status(401);
                    done();
                }).timeout(5000);
        });
        it("Manager doesn't exist", done =>{
            chai
                .request(app)
                .post('/api/managers/authenticate')
                .set('Authorization', 'Bearer ' + process.env.BEARER_TOKEN)
                .send(invalidManagerAuth)
                .end((err,res)=>{
                    expect(res).to.have.status(404);
                    done();
                }).timeout(5000);
        });
    });
    describe('Authenticating driver', ()=>{
        it('Driver is valid', done =>{
            chai
                .request(app)
                .post('/api/drivers/authenticate')
                .set('Authorization', 'Bearer ' + process.env.BEARER_TOKEN)
                .send(successDriverAuth)
                .end((err,res)=>{
                    expect(res).to.have.status(200);
                    expect(res).to.be.json;
                    expect(res.body.id).to.equals(driverAuthResponse.id);
                    done();
                }).timeout(5000);
        });
        it('Driver not valid (Account exists but incorrect password)', done =>{
            chai
                .request(app)
                .post('/api/drivers/authenticate')
                .set('Authorization', 'Bearer ' + process.env.BEARER_TOKEN)
                .send(failDriverAuth)
                .end((err,res)=>{
                    expect(res).to.have.status(401);
                    done();
                }).timeout(5000);
        });
        it("Driver doesn't exist", done =>{
            chai
                .request(app)
                .post('/api/drivers/authenticate')
                .set('Authorization', 'Bearer ' + process.env.BEARER_TOKEN)
                .send(notFoundDriverAuth)
                .end((err,res)=>{
                    expect(res).to.have.status(404);
                    done();
                }).timeout(5000);
        });
    });
    describe('Update driver password', ()=>{
        it("Valid token and id (successful password update)", done =>{
            chai
                .request(app)
                .put('/api/drivers/16/password')
                .set('Authorization', 'Bearer ' + process.env.BEARER_TOKEN)
                .send(updateDriverPassword)
                .end((err,res)=>{
                    expect(res).to.have.status(204);
                    done();
                }).timeout(5000);
        });
        it("Invalid token", done =>{
            chai
                .request(app)
                .put('/api/drivers/16/password')
                .set('Authorization', 'Bearer ' + process.env.BEARER_TOKEN)
                .send(invalidupdateDriverPassword)
                .end((err,res)=>{
                    expect(res).to.have.status(404);
                    done();
                }).timeout(5000);
        });
        it("Invalid :driverid", done =>{
            chai
                .request(app)
                .put('/api/drivers/0/password')
                .set('Authorization', 'Bearer ' + process.env.BEARER_TOKEN)
                .send(updateDriverPassword)
                .end((err,res)=>{
                    expect(res).to.have.status(404);
                    done();
                }).timeout(5000);
        });
    });
    describe('Current driver location', ()=>{
        it("Update driver location", done =>{
            chai
                .request(app)
                .put('/api/location/16')
                .set('Authorization', 'Bearer ' + process.env.BEARER_TOKEN)
                .send(setDriverLocation)
                .end((err,res)=>{
                    expect(res).to.have.status(204);
                    done();
                }).timeout(5000);
        });
        it("Get driver location", done =>{
            chai
                .request(app)
                .get('/api/location/driver?id=16')
                .set('Authorization', 'Bearer ' + process.env.BEARER_TOKEN)
                .send()
                .end((err,res)=>{
                    expect(res).to.have.status(200);
                    expect(res).to.be.json;
                    expect(res.body.drivers[0].id).to.equals(responseGetLocation.drivers[0].id);
                    expect(res.body.drivers[0].name).to.equals(responseGetLocation.drivers[0].name);
                    expect(res.body.drivers[0].surname).to.equals(responseGetLocation.drivers[0].surname);
                    expect(res.body.drivers[0].latitude).to.equals(responseGetLocation.drivers[0].latitude);
                    expect(res.body.drivers[0].longitude).to.equals(responseGetLocation.drivers[0].longitude);
                    done();
                }).timeout(5000);
        });
    });
});