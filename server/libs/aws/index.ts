import { KMS } from 'aws-sdk';
import { AwsConfig } from '../types'

const getAwsConfig = () => {
    return new KMS({ region: 'us-west-1' });
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
                resolve(data.Plaintext!.toString);
            }
        });
    });
}