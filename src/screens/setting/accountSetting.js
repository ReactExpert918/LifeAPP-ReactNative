import React, { useState, useEffect } from 'react';
import { useSelector } from 'react-redux';
import { Text, View, Image, TouchableOpacity } from 'react-native';
import { useNavigation } from '@react-navigation/native';

import { Container, Header } from '../../components';
import { images } from '../../assets/pngs';
import { AccountSettingListComponent } from './component/accountSettingListComponent';
import { UpdateName } from './component/updateNameComponent';
import { firebaseSDK } from '../../services/firebase';
import { MEDIA_FOLDER } from '../../services/firebase/storage';
import { getImagePath } from '../../utils/media';
import { UpdatePassword } from './component/updatePasswordComponent';
import { UpdatePhoneComponent } from './component/updatePhoneComponent';
import { styles } from './styles';

export const AccountSetting = () => {
  const navigation = useNavigation();
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
    console.log('====setting', fileName);
    const path = await getImagePath(fileName, MEDIA_FOLDER.USER);
    if (path) {
      setImage_url(path);
    }
  };

  useEffect(() => {
    getUserInfo(user.objectId);
  }, []);

  useEffect(() => {
    if (title != '' && title !== 'Password' && title != 'Phone Number') {
      isSetVisible(true);
      isSetPass(false);
      isSetPhone(false);
    }
    if (title != '' && title == 'Password') {
      isSetPass(true);
      isSetVisible(false);
      isSetPhone(false);
    }
    if (title != '' && title == 'Phone Number') {
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

  return (
    <Container>
      <Header
        title="Account Settings"
        firstClick={onBack}
        secondClick={onBack}
      />
      <View style={styles.container}>
        <View style={styles.topContainer}>
          <Text style={styles.title}>Account Settings</Text>
        </View>
        <View style={styles.mainContainer}>
          <View style={styles.avatarContanier}>
            <TouchableOpacity>
              <Image style={styles.avatarImage} source={{ uri: image_uri }} />
              <Image style={styles.iconImage} source={images.camera} />
            </TouchableOpacity>
          </View>
          <AccountSettingListComponent
            title="Name"
            value={name}
            click={setTitle}
          />
          <AccountSettingListComponent
            title="Username"
            value={username}
            click={setTitle}
          />
          <AccountSettingListComponent
            title="Password"
            value={username}
            type="pass"
            click={setTitle}
          />
          <AccountSettingListComponent
            title="Phone Number"
            value={phone}
            click={setTitle}
          />
          <AccountSettingListComponent
            title="Email Address"
            value={email}
            click={setTitle}
          />
          <AccountSettingListComponent
            title="Delete Account"
            type="button"
            click={setTitle}
          />
        </View>
        {isVisible && (
          <UpdateName
            title={title}
            name={name}
            username={username}
            email={email}
            click={isSetVisible}
          />
        )}
        {isPass && <UpdatePassword title={title} click={isSetPass} />}
        {isPhone && <UpdatePhoneComponent title={title} click={isSetPhone} />}
      </View>
    </Container>
  );
};
