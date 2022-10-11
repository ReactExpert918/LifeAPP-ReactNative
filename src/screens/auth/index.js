import React from 'react';
import { View, Text, SafeAreaView, Image } from 'react-native';
import { useNavigation } from '@react-navigation/native';

import { Button } from 'react-native-paper';
import { colors } from '../../assets/colors';
import { images } from '../../assets/pngs';
import { textStyles } from '../../common/text.styles';
import { Spacer } from '../../components';
import { styles } from './styles';

export const AuthScreen = () => {
  const navigation = useNavigation();
  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.topContainer}>
        <Image source={images.logo} style={styles.logo} />
        <Spacer top={5} />
        <Text style={textStyles.primaryBold}>Easy, safe and SECURE</Text>
        <Text style={textStyles.primaryThin}>Get started with LIFE app</Text>
      </View>
      <View style={styles.bottomContainer}>
        <Button
          mode="contained"
          color={colors.ui.primary}
          style={styles.loginButton}
          uppercase={false}
          onPress={() => navigation.navigate('Login')}
        >
          Log in
        </Button>
        <Button
          mode="outlined"
          color={colors.ui.primary}
          style={styles.signupButton}
          uppercase={false}
          onPress={() => navigation.navigate('SignUp')}
        >
          Sign up
        </Button>
      </View>
    </SafeAreaView>
  );
};
