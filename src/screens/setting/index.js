/* eslint-disable react/prop-types */
import React from 'react';
import { Text, View, Image, TouchableOpacity, Alert } from 'react-native';
import { useDispatch } from 'react-redux';

import { ContainerComponent } from '../../components/container.component';
import { HeaderComponent } from '../../components/header.component';
import { SettingStyle } from './style';
import { SettingListComponent } from './component/settingListComponent';
import { images } from '../../assets/pngs';
import { APP_NAVIGATION } from '../../constants/app';
import { firebaseSDK } from '../../services/firebase';
import { logOut } from '../../redux/actions';

export const SettingScreen = ({ navigation }) => {
  const dispatch = useDispatch();
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
    <ContainerComponent>
      <HeaderComponent title="Settings" secondClick={onClickClose} />
      <View style={SettingStyle.container}>
        <View style={SettingStyle.topContainer}>
          <Text style={SettingStyle.title}>General Settings</Text>
        </View>
        <View style={SettingStyle.mainContainer}>
          <SettingListComponent
            title="Account Setting"
            click={goAccountSetting}
            icon={images.setting}
          />
          <SettingListComponent title="Zed Pay" icon={images.zed} />
          <SettingListComponent title="Privacy Police" icon={images.privacy} />
          <SettingListComponent title="About Us" icon={images.help} />
        </View>
        <TouchableOpacity onPress={onSignOut} style={SettingStyle.signout}>
          <Image source={images.signout} style={SettingStyle.image} />
          <Text style={SettingStyle.text}>Sign Out</Text>
        </TouchableOpacity>
      </View>
    </ContainerComponent>
  );
};
