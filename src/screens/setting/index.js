/* eslint-disable react/prop-types */
import React from 'react';
import { Text, View, Image } from 'react-native';
import { ContainerComponent } from '../../components/container.component';
import { HeaderComponent } from '../../components/header.component';
import { SettingStyle } from './style';
import { SettingListComponent } from './component/settingListComponent';
import { images } from '../../assets/pngs';
import { APP_NAVIGATION } from '../../constants/app';

export const SettingScreen = ({ navigation }) => {
  const goAccountSetting = () => {
    navigation.navigate(APP_NAVIGATION.account_setting);
  };
  return(
    <ContainerComponent>
      <HeaderComponent title='Settings' firstClick={null} />
      <View style={SettingStyle.container}>
        <View style={SettingStyle.topContainer}>
          <Text style={SettingStyle.title}>General Settings</Text>
        </View>
        <View style={SettingStyle.mainContainer}>
          <SettingListComponent title='Account Setting' click={goAccountSetting} icon={images.setting}/>
          <SettingListComponent title='Zed Pay' icon={images.zed}/>
          <SettingListComponent title='Privacy Police' icon={images.privacy}/>
          <SettingListComponent title='About Us' icon={images.help}/>
        </View>
        <View style={SettingStyle.signout}>
          <Image 
            source={images.signout}
            style={SettingStyle.image} 
          />
          <Text style={SettingStyle.text}>
            Sign Out
          </Text>
        </View>
      </View>
    </ContainerComponent>
  );
};