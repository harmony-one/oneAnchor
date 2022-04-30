import { KMS } from 'aws-sdk';
import { AwsConfig } from '../types'

const getAwsConfig = () => {
    const awsConfig: AwsConfig = {
        accessKeyId: '',
        secretAccessKey: '',
        region: 'us-west-1'
    };
    return new KMS(awsConfig);
}
    
const awsKMS = getAwsConfig();

export async function decrypt(buffer: string) {
    return new Promise((resolve, reject) => {
        const params = {
            CiphertextBlob: buffer
        };
        awsKMS.decrypt(params, (err, data) => {
            if (err) {
                reject(err);
            } else {
                resolve(data.Plaintext.toString);
            }
        });
    });
}