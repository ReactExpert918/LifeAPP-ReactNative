import React, { useState, useEffect } from "react";
import { useSelector } from "react-redux";
import { ContainerComponent } from "../../components/container.component";
import { View, Text, Image, ScrollView, TouchableOpacity, Button } from "react-native";
import { colors } from "../../assets/colors";
import { FriendHeader } from "./component/friendHeader";
import { Buttons } from "../../components/Button/Button";
import { ButtonContainer } from "../../components/Button/ButtonContainer";
import { CreateGroup } from "./createGroup";
import { FriendSection } from "./friendSection";
import { friendStyle } from "./style"
import { images } from "../../assets/pngs"
import { ChatModal } from "./component/chatModal";
import { ChatExpand } from "./component/chatExpand";
import { APP_NAVIGATION } from '../../constants/app'

export const FriendScreen = ({ navigation }) => {
  const [recommandFriend, setRecommandFriend] = 
        useState(
          [{username: "Andrea", type: 'recommand'}, {username: "Andrea2", type: 'recommand'}, 
          {username: "Andrea3", type: 'recommand'}, {username: "Andrea4", type: 'recommand'},
          {username: "Andrea5", type: 'recommand'}
        ])
  const [requestFriend, setrequestFriend] = 
        useState(
          [
            {username: "Boris", type: 'request'}, {username: "Boris2", type: 'request'}
        ])
  const isModalVisible = useSelector(state => state.Friend.show);
  const [isExpandVisible, isSetExpandVisibily] = useState(false); 

  const onClickSearch = () => {
    navigation.navigate(APP_NAVIGATION.friend_search);
  };

  const onClickQR = () => {
    navigation.navigate(APP_NAVIGATION.friend_qrcode);
  };

  return (
    <ContainerComponent>
      <FriendHeader title="Add Friends"/>
      <View style={friendStyle.divider}></View>
      <View style={friendStyle.mainContainer}>
        <View style={friendStyle.topContainer}>
          <ButtonContainer>
            <Buttons 
              text="QR code" 
              image={images.ic_qrcode} 
              color={colors.ui.white}
              onPress={onClickQR}
            />
          </ButtonContainer>
          <ButtonContainer>
            <Buttons 
              text="Search" 
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
            {
              requestFriend.length > 0 &&(
                <FriendSection 
                  title="New Friend Requests"
                  items={requestFriend}
                  onNavigate={null}
                />
            )}
            {recommandFriend.length > 0 &&(
              <FriendSection 
                title="Recommandation Friends"
                items={recommandFriend}
                onNavigate={null}
              />
            )}
          </ScrollView>
        </View>
      </View>
      <ChatModal show={isModalVisible} />
      {
        isExpandVisible && (
          <ChatExpand />
        )
      }
    </ContainerComponent>
  );
};