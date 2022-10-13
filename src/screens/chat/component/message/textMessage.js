import React from 'react';
import { colors } from '../../../../assets/colors';
import styled from 'styled-components';
import { images } from '../../../../assets/pngs';
import { TouchableOpacity, View, Text, Image } from 'react-native';
import { personComponentStyle } from '../chatComponentStyled';
import { DateTimeComponent } from '../dateTimeComponent';

const Container = styled.View`
  padding: 10px;
  width: auto;
  max-width: ${(props) => (props.maxWidth)};
  margin-top: 8px;
  align-items: flex-end;
  border-top-left-radius: 12px;
  border-top-right-radius: 12px;
  border-bottom-left-radius: ${(props) => (props.datas.username=='Andrea' ? '12px' : '0px')};
  border-bottom-right-radius: ${(props) => (props.datas.username=='Andrea' ? '0px' : '12px')};
  ${(props) =>
    !props.datas.username=='Andrea' &&
    `border-width: 1px; border-color: ${colors.ui.gray};`}
  background-color: ${(props) =>
    props.datas.username=='Andrea'
      ? colors.ui.primary
      : colors.bg.lightgray};};
`;

const Texts = styled.Text`
  padding: 10px;
  color: ${(props) => (props.datas.username=='Andrea' ? colors.text.white : colors.text.black)};
  font-size: 14px;
  font-weight: 500;
  min-width: 50px;
`;

export const TextMessage = ({ data, maxWidth }) => {
  return(
    <Container datas={data} maxWidth={maxWidth}>
      <Texts
        variant="label"
        datas={data}
      >
        {data.message}
      </Texts>

      <DateTimeComponent
        color={data.username=='Andrea' ? colors.text.white : colors.text.gray}
        timeStamp={data.createdAt}
      />
    </Container>
  );
};