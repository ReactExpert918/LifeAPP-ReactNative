import React, { useState } from 'react';
import { Alert, Text, View } from 'react-native';
import { Button, TextInput } from 'react-native-paper';
import PropTypes from 'prop-types';

import { textStyles } from '../../../../common/text.styles';
import { Spacer } from '../../../../components';
import { isValidEmail } from '../../../../utils/validators';
import { styles } from './styles';
import { colors } from '../../../../assets/colors';

export const BasicInformation = ({ setUser }) => {
  const [email, setEmail] = useState('');
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [confirm, setConfirm] = useState('');

  const onNext = () => {
    if (!email) {
      Alert.alert('Attention', 'Please enter email!', [
        {
          text: 'OK',
          onPress: () => null,
          style: 'cancel',
        },
      ]);
      return;
    }

    if (!isValidEmail(email)) {
      Alert.alert('Attention', 'Please enter correct email!', [
        {
          text: 'OK',
          onPress: () => null,
          style: 'cancel',
        },
      ]);
      return;
    }

    if (!username) {
      Alert.alert('Attention', 'Please enter username!', [
        {
          text: 'OK',
          onPress: () => null,
          style: 'cancel',
        },
      ]);
      return;
    }

    if (!password) {
      Alert.alert('Attention', 'Please enter password!', [
        {
          text: 'OK',
          onPress: () => null,
          style: 'cancel',
        },
      ]);
      return;
    }

    if (password.length < 6) {
      Alert.alert('Attention', 'Please enter correct Password!', [
        {
          text: 'OK',
          onPress: () => null,
          style: 'cancel',
        },
      ]);
      return;
    }

    if (!confirm) {
      Alert.alert('Attention', 'Please confirm password!', [
        {
          text: 'OK',
          onPress: () => null,
          style: 'cancel',
        },
      ]);
      return;
    }

    if (password != confirm) {
      Alert.alert('Attention', "Password doesn't match", [
        {
          text: 'OK',
          onPress: () => null,
          style: 'cancel',
        },
      ]);
      return;
    }

    setUser(username, email, password);
  };

  return (
    <View style={styles.container}>
      <View style={styles.leftContainer}>
        <Text style={textStyles.blackTitleBold}>
          {'Please fill basic details\nto complete registration'}
        </Text>
        <Spacer top={16} />
        <Text style={textStyles.grayThin}>Email</Text>
        <Spacer top={2} />
        <TextInput
          mode="outlined"
          placeholder="Eg.john@gmail.com"
          textContentType="emailAddress"
          keyboardType="email-address"
          autoCapitalize="none"
          value={email}
          onChangeText={(text) => setEmail(text)}
          outlineColor={'transparent'}
          activeOutlineColor={'transparent'}
          selectionColor={colors.ui.primary}
          style={{ width: '100%' }}
        />
        <Spacer top={16} />
        <Text style={textStyles.grayThin}>Username</Text>
        <Spacer top={2} />
        <TextInput
          mode="outlined"
          label="Username"
          placeholder="Username"
          autoCapitalize="none"
          value={username}
          onChangeText={(text) => setUsername(text)}
          outlineColor={'transparent'}
          activeOutlineColor={'transparent'}
          selectionColor={colors.ui.primary}
          style={{ width: '100%' }}
        />
        <Spacer top={16} />
        <Text style={textStyles.grayThin}>Password</Text>
        <Spacer top={2} />
        <TextInput
          mode="outlined"
          placeholder="Password"
          autoCapitalize="none"
          secureTextEntry={true}
          value={password}
          onChangeText={(text) => setPassword(text)}
          outlineColor={'transparent'}
          activeOutlineColor={'transparent'}
          selectionColor={colors.ui.primary}
          style={{ width: '100%' }}
        />
        <Spacer top={16} />
        <Text style={textStyles.grayThin}>Confirm Password</Text>
        <Spacer top={2} />
        <TextInput
          mode="outlined"
          placeholder="Password"
          autoCapitalize="none"
          secureTextEntry={true}
          value={confirm}
          onChangeText={(text) => setConfirm(text)}
          outlineColor={'transparent'}
          activeOutlineColor={'transparent'}
          selectionColor={colors.ui.primary}
          style={{ width: '100%' }}
        />
        <Spacer top={16} />
        <Button
          mode="contained"
          color={colors.ui.primary}
          style={styles.loginButton}
          onPress={onNext}
        >
          Next
        </Button>
      </View>
    </View>
  );
};

BasicInformation.propTypes = {
  setUser: PropTypes.func.isRequired,
};
