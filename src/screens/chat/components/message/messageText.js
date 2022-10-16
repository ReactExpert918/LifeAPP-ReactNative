import React from 'react';
import styled from 'styled-components/native';
import PropTypes from 'prop-types';
import { Text } from 'react-native';

import { Spacer } from '../../../../components';
import { DateTime } from '../dateTime';
import { colors } from '../../../../assets/colors';
import { textStyles } from '../../../../common/text.styles';

const Container = styled.View`
  padding: 8px;
  max-width: ${(props) => props.maxWidth};
  align-items: flex-end;
  border-top-left-radius: 12px;
  border-top-right-radius: 12px;
  border-bottom-left-radius: ${(props) => (props.isOwner ? '12px' : '0px')};
  border-bottom-right-radius: ${(props) => (props.isOwner ? '0px' : '12px')};
  background-color: ${(props) =>
    props.isOwner ? colors.ui.secondary : colors.bg.lightgray}};
`;

export const MessageText = ({ message, isOwner, maxWidth }) => {
  return (
    <Container isOwner={isOwner} maxWidth={maxWidth}>
      <Text
        style={[
          textStyles.grayMediumThin,
          {
            minWidth: 50,
            color: isOwner ? colors.text.white : colors.text.black,
          },
        ]}
      >
        {message.text}
      </Text>

      <Spacer top={16} />

      <DateTime
        color={isOwner ? colors.text.white : colors.text.gray}
        timeStamp={message.createdAt}
      />
    </Container>
  );
};

MessageText.propTypes = {
  message: PropTypes.string,
  isOwner: PropTypes.bool,
  maxWidth: PropTypes.number,
};
