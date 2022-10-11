/* eslint-disable react/prop-types */
import React, { useState, useEffect } from 'react';
import { useSelector } from 'react-redux';
import { ContainerComponent } from '../../components/container.component';
import { HeaderComponent } from '../../components/header.component';
import {
  View,
  ScrollView,
} from 'react-native';
import { colors } from '../../assets/colors';
import { Buttons } from '../../components/Button/Button';
import { ButtonContainer } from '../../components/Button/ButtonContainer';
import { CreateGroup } from './createGroup';
import { FriendSection } from './friendSection';
import { friendStyle } from './style';
import { images } from '../../assets/pngs';
import { ChatModal } from './component/chatModal';
import { ChatExpand } from './component/chatExpand';
import { APP_NAVIGATION } from '../../constants/app';
import { firebaseSDK } from '../../services/firebase';

export const FriendScreen = ({ navigation }) => {
  const recommandFriend = [
    { username: 'Andrea', type: 'recommand' },
    { username: 'Andrea2', type: 'recommand' },
    { username: 'Andrea3', type: 'recommand' },
    { username: 'Andrea4', type: 'recommand' },
    { username: 'Andrea5', type: 'recommand' },
  ];
  const [requestFriend, setRequestFriend] = useState([]);
  const isModalVisible = useSelector((state) => state.Friend.show);
  const showModalData = useSelector((state) => state.Friend.data);
  const { user } = useSelector((state) => state.Auth);
  const [isExpandVisible, isSetExpandVisibily] = useState(false);

  useEffect(() => {
    getNewFriends(user.uid);
  }, []);

  const getNewFriends = async(friend_id) => {
    let result = [];
    let friends = await firebaseSDK.getNewFriends(friend_id);
    Promise.all(friends)
      .then((res) =>{ 
        res.map((friend) => {
          result.push(friend[0]);
        });
        setRequestFriend(result);
      });
  };

  const onClickSearch = () => {
    navigation.navigate(APP_NAVIGATION.friend_search);
  };

  const onClickQR = () => {
    console.log('123123');
    navigation.navigate(APP_NAVIGATION.friend_qrcode);
  };

  const onClickSetting = () => {
    navigation.navigate(APP_NAVIGATION.setting);
  };

  return (
    <ContainerComponent>
      <HeaderComponent title='Add Friends' firstClick={onClickSetting} />
      <View style={friendStyle.divider}></View>
      <View style={friendStyle.mainContainer}>
        <View style={friendStyle.topContainer}>
          <ButtonContainer>
            <Buttons
              text='QR code'
              image={images.ic_qrcode}
              color={colors.ui.white}
              onPress={onClickQR}
            />
          </ButtonContainer>
          <ButtonContainer>
            <Buttons
              text='Search'
              image={images.ic_search}
              color={colors.ui.white}
              onPress={onClickSearch}
            />
          </ButtonContainer>
        </View>
        <View style={friendStyle.container}>
          <View>
            <CreateGroup />
          </View>
          <View style={friendStyle.divider}></View>
          <ScrollView>
            {requestFriend.length > 0 && (
              <FriendSection
                title='New Friend Requests'
                items={requestFriend}
                onNavigate={null}
              />
            )}
            {recommandFriend.length > 0 && (
              <FriendSection
                title='Recommandation Friends'
                items={recommandFriend}
                onNavigate={null}
              />
            )}
          </ScrollView>
        </View>
      </View>
      <ChatModal data={showModalData} show={isModalVisible} />
      {isExpandVisible && <ChatExpand />}
    </ContainerComponent>
  );
};
