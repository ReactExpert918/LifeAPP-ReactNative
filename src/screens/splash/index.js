import React from 'react';
import { View, Image } from 'react-native';
import { Images } from '../../assets/images';
import { styles } from './styled';

const SplashScreen = () => {
  return (
    <View style={styles.container}>
      <Image source={Images.logo} style={styles.logo} />
    </View>
  );
};

export default SplashScreen;
