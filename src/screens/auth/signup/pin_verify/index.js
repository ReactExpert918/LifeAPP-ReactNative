import React, { useRef, useState } from 'react';
import { Text, TouchableOpacity, View } from 'react-native';
import SmoothPinCodeInput from 'react-native-smooth-pincode-input';
import PropTypes from 'prop-types';
import Ionicons from 'react-native-vector-icons/Ionicons';

import { textStyles } from '../../../../common/text.styles';
import { Spacer } from '../../../../components';
import { styles } from './styles';
import { colors } from '../../../../assets/colors';

export const PincodeVerify = ({ onVerify }) => {
  const [code, setCode] = useState('');
  const pinInput = useRef(null);

  return (
    <>
      <View style={styles.container}>
        <Text style={[textStyles.blackTitleBold, { textAlign: 'center' }]}>
          {'Please Enter the Code you\nreceived by SMS'}
        </Text>
        <Spacer top={16} />
        <SmoothPinCodeInput
          ref={pinInput}
          value={code}
          onTextChange={(text) => setCode(text)}
          codeLength={6}
        />
      </View>
      <View style={styles.bottomContainer}>
        <TouchableOpacity
          onPress={() => onVerify(code)}
          disabled={code.length !== 6}
          style={[
            styles.nextButton,
            {
              backgroundColor:
                code.length == 6 ? colors.ui.primary : colors.bg.lightgray,
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

PincodeVerify.propTypes = {
  onVerify: PropTypes.func.isRequired,
};
