import React, { useRef, useState } from 'react';
import { Text, TouchableOpacity, View } from 'react-native';
import PropTypes from 'prop-types';
import PhoneInput from 'react-native-phone-number-input';
import Ionicons from 'react-native-vector-icons/Ionicons';

import { textStyles } from '../../../../common/text.styles';
import { Spacer } from '../../../../components';
import { commonStyles } from '../../../../common/common.styles';
import { colors } from '../../../../assets/colors';
import { styles } from './styles';

export const PhoneVerify = ({ onSendCode }) => {
  const [phoneNumber, setPhoneNumber] = useState('');
  const phoneInput = useRef(null);

  return (
    <>
      <View style={styles.container}>
        <Text style={textStyles.blackTitleBold}>
          {'What is the phone\nnumber for this\ndevice?'}
        </Text>
        <Spacer top={16} />
        <PhoneInput
          ref={phoneInput}
          defaultValue={phoneNumber}
          defaultCode={'JP'}
          layout="first"
          autoFocus
          onChangeFormattedText={(text) => setPhoneNumber(text)}
          containerStyle={{ width: '100%' }}
        />
      </View>
      <View style={styles.bottomContainer}>
        <View style={commonStyles.flex}>
          <Text style={textStyles.graySmall}>
            {
              'By continuing you will receive an SMS for\nverification. Messages and data\nrates may apply.'
            }
          </Text>
        </View>
        <TouchableOpacity
          onPress={() => onSendCode(phoneNumber)}
          disabled={phoneNumber.length < 9}
          style={[
            styles.nextButton,
            {
              backgroundColor:
                phoneNumber.length > 9
                  ? colors.ui.primary
                  : colors.bg.lightgray,
            },
          ]}
        >
          <Ionicons
            size={32}
            color={colors.ui.white}
            name="arrow-forward-sharp"
          />
        </TouchableOpacity>
      </View>
    </>
  );
};

PhoneVerify.propTypes = {
  onSendCode: PropTypes.func.isRequired,
};
