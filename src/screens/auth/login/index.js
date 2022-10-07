import React, { useState } from 'react';
import {
  Image,
  SafeAreaView,
  View,
  Text,
  TouchableOpacity,
  Alert,
} from 'react-native';
import { KeyboardAwareScrollView } from 'react-native-keyboard-aware-scroll-view';
import { Button, TextInput } from 'react-native-paper';
import { useNavigation } from '@react-navigation/native';
import { useDispatch } from 'react-redux';

import { colors } from '../../../assets/colors';
import { images } from '../../../assets/pngs';
import { textStyles } from '../../../common/text.styles';
import { Spacer } from '../../../components';
import { styles } from './styles';
import { isValidEmail } from '../../../utils/validators';
import { firebaseSDK } from '../../../services/firebase';
import { AUTH_ACTION } from '../../../constants/redux';

export const LoginScreen = () => {
  const navigation = useNavigation();
  const dispatch = useDispatch();
  const [email, setEmail] = useState();
  const [password, setPassword] = useState();
  const [isLoading, setIsLoading] = useState(false);

  const onLogin = async () => {
    if (!email) {
      Alert.alert('Attention', 'Please enter email!', [
        {
          text: 'OK',
          onPress: () => null,
          style: 'cancel',
        },
      ]);
      return;
    }

    if (!isValidEmail(email)) {
      Alert.alert('Attention', 'Please enter correct email!', [
        {
          text: 'OK',
          onPress: () => null,
          style: 'cancel',
        },
      ]);
      return;
    }

    if (!password) {
      Alert.alert('Attention', 'Please enter password!', [
        {
          text: 'OK',
          onPress: () => null,
          style: 'cancel',
        },
      ]);
      return;
    }

    if (password.length < 6) {
      Alert.alert('Attention', 'Please enter correct Password!', [
        {
          text: 'OK',
          onPress: () => null,
          style: 'cancel',
        },
      ]);
      return;
    }
    setIsLoading(true);
    const userData = await firebaseSDK.signInEmailPassword(email, password);
    if (userData) {
      dispatch({
        type: AUTH_ACTION.USER_LOGIN,
        payload: { user: userData.user },
      });
    }
    setIsLoading(false);
  };

  return (
    <SafeAreaView style={styles.container}>
      <KeyboardAwareScrollView contentContainerStyle={styles.content}>
        <View style={styles.topContainer}>
          <Image source={images.logo} style={styles.logo} />
          <Spacer top={2} />
          <Text style={textStyles.blackBold}>Login to your account</Text>
          <View style={styles.loginContainer}>
            <Text style={textStyles.grayThin}>Email</Text>
            <Spacer top={2} />
            <TextInput
              mode="outlined"
              placeholder="Eg.john@gmail.com"
              textContentType="emailAddress"
              keyboardType="email-address"
              autoCapitalize="none"
              value={email}
              onChangeText={(text) => setEmail(text)}
              outlineColor={'transparent'}
              activeOutlineColor={'transparent'}
              selectionColor={colors.ui.primary}
              style={{ width: '100%' }}
            />
            <Spacer top={16} />
            <Text style={textStyles.grayThin}>Password</Text>
            <Spacer top={2} />
            <TextInput
              mode="outlined"
              placeholder="Password"
              autoCapitalize="none"
              secureTextEntry={true}
              value={password}
              onChangeText={(text) => setPassword(text)}
              outlineColor={'transparent'}
              activeOutlineColor={'transparent'}
              selectionColor={colors.ui.primary}
              style={{ width: '100%' }}
            />
            <Button
              mode="contained"
              color={colors.ui.primary}
              style={styles.loginButton}
              loading={isLoading}
              onPress={onLogin}
            >
              login
            </Button>
            {/* <Button
              mode="text"
              color={colors.bg.black}
              style={styles.forgotButton}
              uppercase={false}
            >
              Forgot Password?
            </Button> */}
          </View>
        </View>
        <View style={styles.bottomContainer}>
          <Text style={textStyles.blackSmall}>
            Don't have an account? Please
          </Text>
          <TouchableOpacity onPress={() => navigation.navigate('SignUp')}>
            <Text style={styles.registerLabel}>{' Register '}</Text>
          </TouchableOpacity>
          <Text style={textStyles.blackSmall}>now</Text>
        </View>
      </KeyboardAwareScrollView>
    </SafeAreaView>
  );
};
