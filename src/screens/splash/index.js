import React, { useEffect } from 'react';
import { View, Image } from 'react-native';
import { useDispatch } from 'react-redux';

import { images } from '../../assets/pngs';
import { AUTH_ACTION } from '../../constants/redux';
import { firebaseSDK } from '../../services/firebase';
import { styles } from './styles';

export const SplashScreen = () => {
  const dispatch = useDispatch();
  useEffect(() => {
    firebaseSDK.checkAuthedUser(async (user) => {
      if (user) {
        const userProfile = await firebaseSDK.getUser(user.uid);
        if (userProfile) {
          dispatch({
            type: AUTH_ACTION.USER_LOGIN,
            payload: { user: userProfile },
          });
        }
      }
      dispatch({ type: AUTH_ACTION.UPDATE_SPLASH });
    });
  }, []);

  return (
    <View style={styles.container}>
      <Image source={images.logo} style={styles.logo} />
    </View>
  );
};
