import React, { useState } from 'react';
import { ContainerComponent } from '../../components/container.component';
import { View, ScrollView } from 'react-native';
import { colors } from '../../assets/colors';
import { FriendHeader } from './component/friendHeader';
import { Button } from '../../components/Button/Button';
import { ButtonContainer } from '../../components/Button/ButtonContainer';
import { CreateGroup } from './createGroup';
import { FriendSection } from './friendSection';
import { friendStyle } from './style';
import { images } from '../../assets/pngs';

export const FriendScreen = () => {
  const [recommandFriend, setRecommandFriend] = useState([
    { username: 'Andrea' },
    { username: 'Andrea2' },
    { username: 'Andrea3' },
    { username: 'Andrea4' },
    { username: 'Andrea5' },
  ]);
  return (
    <ContainerComponent>
      <FriendHeader />
      <View style={friendStyle.divider}></View>
      <View style={friendStyle.mainContainer}>
        <View style={friendStyle.topContainer}>
          <ButtonContainer>
            <Button
              text="QR code"
              image={images.ic_qrcode}
              color={colors.ui.white}
            />
          </ButtonContainer>
          <ButtonContainer>
            <Button
              text="Search"
              image={images.ic_search}
              color={colors.ui.white}
            />
          </ButtonContainer>
        </View>
        <View style={friendStyle.container}>
          <View>
            <CreateGroup />
          </View>
          <View style={friendStyle.divider}></View>
          <ScrollView>
            {recommandFriend.length > 0 && (
              <FriendSection
                title="Recommandation Friends"
                items={recommandFriend}
                onNavigate={null}
              />
            )}
          </ScrollView>
        </View>
      </View>
    </ContainerComponent>
  );
};
