import React, { useState } from 'react';
import { ActivityIndicator, Alert, SafeAreaView, View } from 'react-native';
import Ionicons from 'react-native-vector-icons/Ionicons';
import PropTypes from 'prop-types';
import { KeyboardAwareScrollView } from 'react-native-keyboard-aware-scroll-view';
import ImageResizer from 'react-native-image-resizer';
import { useDispatch } from 'react-redux';

import { colors } from '../../../assets/colors';
import { images } from '../../../assets/pngs';
import { styles } from './styles';
import { useNavigation } from '@react-navigation/native';
import { firebaseSDK } from '../../../services/firebase';
import { PhoneVerify } from './phone_verify';
import { PincodeVerify } from './pin_verify';
import { BasicInformation } from './basic_information';
import { AddAvatar } from './add_avatar';
import { commonStyles } from '../../../common/common.styles';
import { AUTH_ACTION } from '../../../constants/redux';

export const Circle = ({ selected }) => {
  return (
    <View
      style={[
        styles.circle,
        { backgroundColor: selected ? colors.ui.primary : colors.ui.gray },
      ]}
    />
  );
};

Circle.propTypes = {
  selected: PropTypes.bool.isRequired,
};

export const SignUpScreen = () => {
  const dispatch = useDispatch();
  const navigation = useNavigation();
  const [pageIndex, setPageIndex] = useState(0);
  const [confirm, setConfirm] = useState(null);
  const [isLoading, setIsLoading] = useState(false);
  const [username, setUsername] = useState('');

  const onBack = () => {
    if (pageIndex > 0) {
      setPageIndex(pageIndex - 1);
    } else {
      navigation.pop();
    }
  };

  const sendCode = async (phoneNumber) => {
    setIsLoading(true);
    try {
      const confirmation = await firebaseSDK.signInWithPhoneNumber(phoneNumber);
      setConfirm(confirmation);
      setPageIndex(1);
    } catch (e) {
      console.log(e);
      Alert.alert('Invalid Number!');
    }
    setIsLoading(false);
  };

  const verifyCode = async (code) => {
    setIsLoading(true);
    try {
      await confirm.confirm(code);
      setIsLoading(false);
      setPageIndex(2);
    } catch (error) {
      setIsLoading(false);
      Alert.alert('Invalid Code');
    }
  };

  const setBasicInformation = (username, email, password) => {
    setIsLoading(true);

    firebaseSDK
      .updateEmail(email)
      .then(() => {
        firebaseSDK
          .updatePassword(password)
          .then(() => {
            setUsername(username);
            setIsLoading(false);
            setPageIndex(3);
          })
          .catch((error) => {
            setIsLoading(false);
            console.log(error);
          });
      })
      .catch((error) => {
        setIsLoading(false);
        console.log(error);
      });
  };

  const onSubmit = (image_path, publicName) => {
    setIsLoading(true);
    console.log('beforeresizedImage');

    ImageResizer.createResizedImage(
      image_path,
      300,
      300,
      'JPEG',
      30,
      0,
      undefined,
      false,
      { mode: 'contain', onlyscaleDown: false }
    )
      .then(async (resizedImage) => {
        const user = await firebaseSDK.authorizedUser();

        await firebaseSDK.uploadAvata(`${user.uid}.jpg`, resizedImage.path);

        const userInfo = {
          username,
          fullname: publicName,
          email: user.email,
          phone: user.phoneNumber,
          objectId: user.uid,
          pictureAt: new Date().getTime(),
          createdAt: new Date().getTime(),
        };

        await firebaseSDK.setUser(userInfo);
        dispatch({
          type: AUTH_ACTION.USER_LOGIN,
          payload: { user: userInfo },
        });
        setIsLoading(false);
      })
      .catch((error) => {
        console.log(error);
      });
  };

  return (
    <>
      <SafeAreaView style={styles.container}>
        <View style={styles.header}>
          <Ionicons
            icon={images.ic_back}
            color={colors.ui.primary}
            size={32}
            name="chevron-back-sharp"
            style={styles.leftIcon}
            onPress={onBack}
          />
          <Circle selected={pageIndex == 0} />
          <Circle selected={pageIndex == 1} />
          <Circle selected={pageIndex == 2} />
          <Circle selected={pageIndex == 3} />
        </View>
        <KeyboardAwareScrollView contentContainerStyle={commonStyles.flex}>
          {pageIndex == 0 ? (
            <PhoneVerify onSendCode={sendCode} />
          ) : pageIndex == 1 ? (
            <PincodeVerify onVerify={verifyCode} />
          ) : pageIndex == 2 ? (
            <BasicInformation setUser={setBasicInformation} />
          ) : (
            <AddAvatar onSubmit={onSubmit} />
          )}
        </KeyboardAwareScrollView>
      </SafeAreaView>
      {isLoading && (
        <View style={styles.loader}>
          <ActivityIndicator color={colors.ui.primary} />
        </View>
      )}
    </>
  );
};
