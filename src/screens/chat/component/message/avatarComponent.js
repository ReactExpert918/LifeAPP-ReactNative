import React from 'react';
import { colors } from '../../../../assets/colors';
import styled from 'styled-components';
import { images } from '../../../../assets/pngs';
import { TouchableOpacity, View, Text, Image } from 'react-native';
import { personComponentStyle } from '../chatComponentStyled';
import { DateTimeComponent } from '../dateTimeComponent';
import { dateStringFromNow } from '../../../../utils/datetime';

const Container = styled.View`
  align-items: ${(props) => (props.data.username=='Andrea' ? 'flex-start' : 'flex-end')};
  border-radius: 12px;
  padding: 10px;
`;

const ImagePhoto = styled.Image`
  width: 60px;
  height: 60px;
  border-radius: 30px;
`;


export const AvatarComponent = ({datas, maxWidth}) => {
  return (
    <Container data={datas} maxWidth={maxWidth}>
      {
        datas.username == 'Andrea' ?
          <ImagePhoto source={images.ic_default_profile} /> :
          <ImagePhoto source={images.ic_add_friend} />
      }
    </Container>
  );
};
