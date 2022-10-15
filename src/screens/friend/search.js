/* eslint-disable react/prop-types */
import React, { useState } from 'react';
import { useSelector } from 'react-redux';
import { Text, View, Dimensions } from 'react-native';
import styled from 'styled-components/native';
import { Container } from '../../components';
import { Header } from '../../components';
import { FriendSection } from './friendSection';
import { searchStyle } from './style';
import { colors } from '../../assets/colors';
import { images } from '../../assets/pngs';
import { Searchbar } from 'react-native-paper';
import Ionicons from 'react-native-vector-icons/Ionicons';
import { ChatExpand } from './component/chatExpand';
import { firebaseSDK } from '../../services/firebase';
import { getmd5 } from '../../utils/cryptor';

const Button = styled.TouchableOpacity`
  align-items: center;
  justify-content: center;
  width: 24px;
  height: 24px;
  border-color: ${colors.bg.gray};
  border-width: ${(props) => (!props.isSelected ? '1px;' : '0px;')};
  border-radius: 12px;
  background-color: ${(props) =>
    props.isSelected ? colors.ui.primary : colors.bg.primary};
`;

const IconCheck = styled(Ionicons).attrs({
  color: colors.ui.white,
  size: 16,
  name: 'md-checkmark',
})``;

const SearchOptions = {
  username: 'Username',
  phone: 'Phone Number',
};

const EmptyImage = styled.Image`
  width: ${(Dimensions.get('window').height / 5) * 2};
  height: ${(Dimensions.get('window').height / 5) * 1.5};
`;

const EmptyText = styled.Text`
  color: ${colors.text.gray};
  text-align: center;
  font-size: 20px;
  font-weight: 400;
  margin-bottom: 20px;
`;

export const FriendSearchScreen = ({ navigation }) => {
  const [searchOption, setSearchOption] = useState(SearchOptions.username);
  const [isExpandVisible, isSetExpandVisibily] = useState(false);
  const [keyword, setKeyword] = useState(null);
  const [friends, setFriends] = useState([]);
  const [is_friend, setIsFriend] = useState(true);
  const { user } = useSelector((state) => state.Auth);

  const onBack = () => {
    navigation.goBack();
  };

  const addFriend = async () => {
    let friend_id = friends[0].objectId;
    const doc_id = getmd5(`${user.id}-${friend_id}`);
    await firebaseSDK.creatFriend(user.uid, friend_id, doc_id);
    isSetExpandVisibily(true);
  };

  const searchKeyword = async () => {
    if (searchOption == SearchOptions.username) {
      const friend = await firebaseSDK.getUserWithName(user.uid, keyword);
      if (friend) {
        setFriends([friend]);
        setIsFriend(true);
      } else {
        setIsFriend(false);
      }
    } else {
      const friend = await firebaseSDK.getUserWithPhonenumber(user.id, keyword);
      if (friend) {
        setFriends([friend]);
        setIsFriend(true);
      } else {
        setIsFriend(false);
      }
    }
  };
  return (
    <Container>
      <Header title="Search Friends" firstClick={onBack} />
      <View style={searchStyle.divider}></View>
      <View style={searchStyle.mainContainer}>
        <View style={searchStyle.topContainer}>
          <Button
            isSelected={searchOption == SearchOptions.username}
            onPress={() => setSearchOption(SearchOptions.username)}
          >
            {searchOption == SearchOptions.username && <IconCheck />}
          </Button>
          <Text style={searchStyle.text}>{SearchOptions.username}</Text>
          <View style={searchStyle.space}></View>
          <Button
            isSelected={searchOption == SearchOptions.phone}
            onPress={() => setSearchOption(SearchOptions.phone)}
          >
            {searchOption == SearchOptions.phone && <IconCheck />}
          </Button>
          <Text style={searchStyle.text}>{SearchOptions.phone}</Text>
        </View>
        <View style={searchStyle.container}>
          <Searchbar
            style={searchStyle.searchStyle}
            clearAccessibilityLabel="Cancel"
            placeholder="Search"
            value={keyword}
            onChangeText={(text) => setKeyword(text)}
            onSubmitEditing={searchKeyword}
          />
        </View>
        {friends.length > 0 ? (
          <View>
            <FriendSection
              title="Showing Results"
              items={friends}
              onNavigate={null}
              onAdd={addFriend}
              state={isExpandVisible}
            />
          </View>
        ) : (
          <View
            style={{
              flex: 1,
              justifyContent: 'center',
              alignItems: 'center',
              backgroundColor: colors.bg.primary,
              width: '100%',
            }}
          >
            <EmptyText>
              {is_friend
                ? `Search friends using their username ${'\n'}  or phone number`
                : 'No user is available by that username'}
            </EmptyText>

            {!is_friend ? (
              <EmptyImage source={images.img_search_no} resizeMode="contain" />
            ) : (
              <EmptyImage source={images.img_search_bg} resizeMode="contain" />
            )}
          </View>
        )}
      </View>
      {isExpandVisible == true ? (
        <ChatExpand data={friends} visible={isSetExpandVisibily} />
      ) : null}
    </Container>
  );
};
