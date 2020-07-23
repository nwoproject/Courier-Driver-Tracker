const express = require('express');
const express = require('express-favicon');
const path = require('path');
const port = process.env.PORT || 3000;
const app = express();

app.use(favicon(__dirname+'/public/favicon.ico'));
app.use(express.static(__dirname));
app.use(express.static(path.join(__dirname, 'public')));

app.get('/*', function(req, res){
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

app.listen(port);