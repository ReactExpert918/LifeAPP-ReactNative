import { FRIEND_STATE } from '../../constants/redux';
 
const initialState = {
  show: false,
};

const Reducer = (state = initialState, action) => {
  switch (action.type) {
  case FRIEND_STATE.REQUEST:
  {
    return {...state, show: action.show, data: action.data};
  }    
          
  default: {
    return state;
  }
  }
};

export default Reducer;
