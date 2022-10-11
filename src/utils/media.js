/* eslint-disable no-async-promise-executor */
import { Platform } from 'react-native';
import RNFS from 'react-native-fs';
import { firebaseSDK } from '../services/firebase';
export const getImagePath = (fileName, media_dir) => {
  return new Promise(async (resolve, reject) => {
    const filePath = `${RNFS.DocumentDirectoryPath}/${fileName}`;
    const exists = await RNFS.exists(filePath);
    if (exists) {
      const realPath = Platform.OS === 'android' ? `file://${filePath}` : filePath;
      resolve(realPath);
      return;
    } else {
      const url = await firebaseSDK.getDownloadURL(`${media_dir}/${fileName}`);
      RNFS.downloadFile({ fromUrl: url, toFile: filePath })
        .promise.then((r) => {
          console.log(r);
          resolve(filePath);
        })
        .catch((error) => {
          console.log(error);
          reject(error);
        });
    }
  });
};
