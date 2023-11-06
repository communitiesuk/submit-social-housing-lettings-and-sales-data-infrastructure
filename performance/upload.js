const { S3Client, PutObjectCommand } = require("@aws-sdk/client-s3");
const fs = require('fs');

var done = false;

const upload = () => {
    const client = new S3Client({ region: "eu-west-1" });
    const key = `report-${Date.now()}.html`
    const fileStream = fs.createReadStream("report.json.html");
    fileStream.on('error', (err) => {
        console.log("File Error", err);
    })
    const command = new PutObjectCommand({
        Bucket: process.env.OUTPUT_BUCKET,
        Key: key,
        Body: fileStream
    });
    client.send(command, function(err, data) {
        if (err) {
            console.log("Error: ", err);
        }
        if (data) {
            console.log("Complete: ", data);
        }

        done = true;
    });
}

const waitForDone = () => {
    if (done) {
        return true;
    } else {
        setTimeout(waitForDone, 1000);
    }
}

upload();
waitForDone();