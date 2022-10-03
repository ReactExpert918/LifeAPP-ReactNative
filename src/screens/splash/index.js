import React, { useEffect } from 'react';
import { View, Image } from 'react-native';
import { useDispatch } from 'react-redux';

import { Images } from '../../assets/images';
import { AUTH_ACTION } from '../../constants/redux';
import { firebaseSDK } from '../../services/firebase';
import { styles } from './styled';

const SplashScreen = () => {
  const dispatch = useDispatch();
  useEffect(() => {
    firebaseSDK.checkAuthedUser(user => {
      if (user) {

      } else {
        
      }
      console.log('======', user)
      dispatch({ type: AUTH_ACTION.UPDATE_SPLASH });
    });
  }, []);

  return (
    <View style={styles.container}>
      <Image source={Images.logo} style={styles.logo} />
    </View>
  );
};

export default SplashScreen;
