import React, { useState } from 'react';
import { View, StyleSheet } from 'react-native';
import { Searchbar } from 'react-native-paper';
import { colors } from '../assets/colors';

const styles = StyleSheet.create({
  container: {
    backgroundColor: colors.ui.primary,
    height: 60,
    padding: 10,
    paddingHorizontal: 20,
  },
  searchStyle: {
    color: colors.text.white,
    height: 40,
    borderRadius: 8,
    backgroundColor: colors.ui.secondary,
  },
});

const SearchBar = () => {
  const [searchKeyword, setSearchKeyword] = useState('');

  return (
    <View style={styles.container}>
      <Searchbar
        style={styles.searchStyle}
        clearAccessibilityLabel="Cancel"
        placeholder="Search"
        value={searchKeyword}
        onChangeText={(text) => setSearchKeyword(text)}
        onSubmitEditing={() => console.log('Search')}
        inputStyle={{ padding: 0 }}
      />
    </View>
  );
};

export default SearchBar;
