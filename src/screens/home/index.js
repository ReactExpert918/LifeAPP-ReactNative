import React, { useEffect, useState } from 'react';
import { View, Text } from 'react-native';
import { useSelector } from 'react-redux';
import { useNavigation } from '@react-navigation/native';

import { textStyles } from '../../common/text.styles';
import { Avatar, SearchBar, Spacer, Header, Container } from '../../components';
import { APP_NAVIGATION } from '../../constants/app';
import { Friends, Groups } from './components';
import { getImagePath } from '../../utils/media';
import { MEDIA_FOLDER } from '../../services/firebase/storage';
import { styles } from './styles';

export const HomeScreen = () => {
  const { user } = useSelector((state) => state.Auth);
  const navigation = useNavigation();
  const [avatar, setAvatar] = useState(null);

  useEffect(() => {
    setImage(`${user.objectId}.jpg`);
  }, []);

  const setImage = async (fileName) => {
    const path = await getImagePath(fileName, MEDIA_FOLDER.USER);
    if (path) {
      setAvatar(path);
    }
  };

  const onClickSetting = () => {
    navigation.navigate(APP_NAVIGATION.setting);
  };

  const onClickFriend = () => {
    navigation.navigate(APP_NAVIGATION.friend_add);
  };

  return (
    <Container>
      <Header
        title="Home"
        firstClick={onClickSetting}
        secondClick={onClickFriend}
      />
      <SearchBar />
      <View style={styles.profileContainer}>
        <Avatar size={50} url={avatar} />
        <Spacer right={16} />
        <View>
          <Text style={textStyles.blackBold}>
            {user.fullname || user.username}
          </Text>
          <Text style={textStyles.grayMediumThin}></Text>
        </View>
      </View>
      <Friends />
      <Groups />
    </Container>
  );
};
