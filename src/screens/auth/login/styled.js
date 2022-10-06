import React from 'react';
import { SafeAreaView } from 'react-native';
import { KeyboardAwareScrollView } from 'react-native-keyboard-aware-scroll-view';

const LoginScreen = () => {
  return (
    <SafeAreaView>
      <KeyboardAwareScrollView></KeyboardAwareScrollView>
    </SafeAreaView>
  );
};

export default LoginScreen;