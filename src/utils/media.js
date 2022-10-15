import { Platform } from 'react-native';
import RNFS from 'react-native-fs';
import { firebaseSDK } from '../services/firebase';
export const getImagePath = async (fileName, media_dir) => {
  try {
    const filePath = `${RNFS.DocumentDirectoryPath}/${fileName}`;
    const exists = await RNFS.exists(filePath);
    if (exists) {
      const realPath =
        Platform.OS === 'android' ? `file://${filePath}` : filePath;
      return realPath;
    } else {
      const url = await firebaseSDK.getDownloadURL(`${media_dir}/${fileName}`);
      return url;
    }
  } catch (e) {
    console.log(e);
    return;
  }
};
