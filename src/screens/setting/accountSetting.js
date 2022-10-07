/* eslint-disable react/prop-types */
import React , {useState, useEffect} from 'react';
import { Text, View, Image, TouchableOpacity } from 'react-native';
import { ContainerComponent } from '../../components/container.component';
import { HeaderComponent } from '../../components/header.component';
import { SettingStyle } from './style';
import { AccountSettingListComponent } from './component/accountSettingListComponent';
import { images } from '../../assets/pngs';
import { UpdateAccount } from './component/updateAccountComponent';

export const AccountSetting = () => {
  const [isVisible, isSetVisible] = useState(false);
  const [title, setTitle] = useState('');
  useEffect(() => {
    if(title != '') {
      isSetVisible(true);
    }
  }, [title]);
  return(
    <ContainerComponent>
      <HeaderComponent title='Account Settings' firstClick={null} />
      <View style={SettingStyle.container}>
        <View style={SettingStyle.topContainer}>
          <Text style={SettingStyle.title}>Account Settings</Text>
        </View>
        <View style={SettingStyle.mainContainer}>
          <View style={SettingStyle.avatarContanier}>
            <TouchableOpacity>
              <Image style={SettingStyle.avatarImage} source={images.ic_default_profile} />
              <Image style={SettingStyle.iconImage} source={images.camera} />
            </TouchableOpacity>
          </View>
          <AccountSettingListComponent title='Name' value='Shane Watson' click={setTitle} />
          <AccountSettingListComponent title='Username' value='shane_watson' click={setTitle}/>
          <AccountSettingListComponent title='Password' value='123123123' type='pass' click={setTitle}/>
          <AccountSettingListComponent title='Phone Number' value='+81-7654321' click={setTitle}/>
          <AccountSettingListComponent title='Email Address' value='shane_watson@gmail.com' click={setTitle}/>
          <AccountSettingListComponent title='Delete Account' type='button' click={setTitle}/>
        </View>
        {isVisible && <UpdateAccount title={title} click={isSetVisible}  />}
      </View>
    </ContainerComponent>
  );
};