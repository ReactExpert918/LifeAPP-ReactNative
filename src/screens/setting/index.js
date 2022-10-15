import React from 'react';
import { Text, View, Image, TouchableOpacity, Alert } from 'react-native';
import { useDispatch } from 'react-redux';
import { useNavigation } from '@react-navigation/native';

import { Container, Header } from '../../components';
import { SettingListComponent } from './component/settingListComponent';
import { images } from '../../assets/pngs';
import { APP_NAVIGATION } from '../../constants/app';
import { firebaseSDK } from '../../services/firebase';
import { logOut } from '../../redux/actions';
import { styles } from './styles';

export const SettingScreen = () => {
  const dispatch = useDispatch();
  const navigation = useNavigation();

  const goAccountSetting = () => {
    navigation.navigate(APP_NAVIGATION.account_setting);
  };

  const onClickClose = () => {
    navigation.goBack();
  };

  const signOut = () => {
    firebaseSDK.signOut().then(() => dispatch(logOut()));
  };

  const onSignOut = () => {
    Alert.alert('Sign Out', 'Are you sure you want to sign out?', [
      { text: 'No', style: 'cancel' },
      {
        text: 'Yes',
        style: 'destructive',
        onPress: signOut,
      },
    ]);
  };

  return (
    <Container>
      <Header title="Settings" secondClick={onClickClose} />
      <View style={styles.container}>
        <View style={styles.topContainer}>
          <Text style={styles.title}>General Settings</Text>
        </View>
        <View style={styles.mainContainer}>
          <SettingListComponent
            title="Account Setting"
            onClick={goAccountSetting}
            icon={images.setting}
          />
          <SettingListComponent title="Zed Pay" icon={images.zed} />
          <SettingListComponent title="Privacy Police" icon={images.privacy} />
          <SettingListComponent title="About Us" icon={images.help} />
        </View>
        <TouchableOpacity onPress={onSignOut} style={styles.signout}>
          <Image source={images.signout} style={styles.image} />
          <Text style={styles.text}>Sign Out</Text>
        </TouchableOpacity>
      </View>
    </Container>
  );
};
