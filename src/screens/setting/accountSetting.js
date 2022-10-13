/* eslint-disable react/prop-types */
import React , {useState, useEffect} from 'react';
import { useSelector } from 'react-redux';
import { Text, View, Image, TouchableOpacity } from 'react-native';
import { ContainerComponent } from '../../components/container.component';
import { HeaderComponent } from '../../components/header.component';
import { SettingStyle } from './style';
import { AccountSettingListComponent } from './component/accountSettingListComponent';
import { images } from '../../assets/pngs';
import { UpdateName } from './component/updateNameComponent';
import { firebaseSDK } from '../../services/firebase';
import { MEDIA_FOLDER } from '../../services/firebase/storage';
import { getImagePath } from '../../utils/media';
import { UpdatePassword } from './component/updatePasswordComponent';
import { UpdatePhoneComponent } from './component/updatePhoneComponent';

export const AccountSetting = ({ navigation }) => {

  const [isVisible, isSetVisible] = useState(false);
  const [isPass, isSetPass] = useState(false);
  const [isPhone, isSetPhone] = useState(false);

  const { user } = useSelector((state) => state.Auth);
  const [title, setTitle] = useState('');
  const [name, setName] = useState('');
  const [username, setUsername] = useState('');
  const [phone, setPhone] = useState('');
  const [email, setEmail] = useState('');
  const [image_uri, setImage_url] = useState(null);

  const setImage = async (fileName) => {
    const path = await getImagePath(fileName, MEDIA_FOLDER.USER);
    if (path) {
      setImage_url(path);
    }
  };

  useEffect(() => {
    getUserInfo(user.uid);
  });

  useEffect(() => {
    if(title != '' && title !== 'Password' && title != 'Phone Number') {
      isSetVisible(true);
      isSetPass(false);
      isSetPhone(false);
    }
    if(title != '' && title == 'Password') {
      isSetPass(true);
      isSetVisible(false);
      isSetPhone(false);
    }
    if(title != '' && title == 'Phone Number') {
      isSetPhone(true);
      isSetPass(false);
      isSetVisible(false);
    }
  }, [title]);

  const getUserInfo = async (user_id) => {
    let result = await firebaseSDK.getUser(user_id);
    setName(result.fullname);
    setUsername(result.username);
    setPhone(result.phone);
    setEmail(result.email);
    setImage(`${result.objectId}.jpg`);
    
  };

  const onBack = () => {
    navigation.goBack();
  };

  return(
    <ContainerComponent>
      <HeaderComponent title='Account Settings' firstClick={onBack} secondClick={onBack} />
      <View style={SettingStyle.container}>
        <View style={SettingStyle.topContainer}>
          <Text style={SettingStyle.title}>Account Settings</Text>
        </View>
        <View style={SettingStyle.mainContainer}>
          <View style={SettingStyle.avatarContanier}>
            <TouchableOpacity>
              <Image style={SettingStyle.avatarImage} source={{uri: image_uri}} />
              <Image style={SettingStyle.iconImage} source={images.camera} />
            </TouchableOpacity>
          </View>
          <AccountSettingListComponent title='Name' value={name} click={setTitle} />
          <AccountSettingListComponent title='Username' value={username} click={setTitle}/>
          <AccountSettingListComponent title='Password' value={username} type='pass' click={setTitle}/>
          <AccountSettingListComponent title='Phone Number' value={phone} click={setTitle}/>
          <AccountSettingListComponent title='Email Address' value={email} click={setTitle}/>
          <AccountSettingListComponent title='Delete Account' type='button' click={setTitle}/>
        </View>
        {isVisible && 
        <UpdateName 
          title={title} 
          name={name} 
          username={username} 
          email={email} 
          click={isSetVisible}  
        />}
        {
          isPass && 
          <UpdatePassword 
            title={title}
            click={isSetPass}
          />
        }
        {
          isPhone && 
          <UpdatePhoneComponent
            title={title}
            click={isSetPhone}
          />
        }
      </View>
    </ContainerComponent>
  );
};