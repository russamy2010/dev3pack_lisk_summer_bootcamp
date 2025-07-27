// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract UserProfile {
    // --- State Variables ---
    // @notice Struct to define the user profile information.
    struct User {
        string name;
        uint age;
        string email;
        uint registrationTimestamp; // Timestamp when the user registered
    }

    // @notice Mapping to store user profiles, where address maps to User struct.
    mapping(address => User) public users;

    // @notice Mapping to track if an address has already registered.
    mapping(address => bool) public isRegistered;

    // --- Events ---
    // @notice Emitted when a new user registers their profile.
    event UserRegistered(address indexed userAddress, string name, uint age, string email, uint timestamp);

    // @notice Emitted when an existing user updates their profile.
    event ProfileUpdated(address indexed userAddress, string newName, uint newAge, string newEmail);

    // --- Functions ---

    /**
     * @dev Allows a new user to register their profile.
     * @param _name The name of the user.
     * @param _age The age of the user.
     * @param _email The email of the user.
     */
    function register(string calldata _name, uint _age, string calldata _email) external {
        // @dev Ensure the user has not registered before.
        require(!isRegistered[msg.sender], "You are already registered.");
        require(bytes(_name).length > 0, "Name cannot be empty.");
        require(bytes(_email).length > 0, "Email cannot be empty.");
        require(_age > 0, "Age must be positive.");

        users[msg.sender] = User({
            name: _name,
            age: _age,
            email: _email,
            registrationTimestamp: block.timestamp // Use block.timestamp for the current time
        });

        isRegistered[msg.sender] = true;

        emit UserRegistered(msg.sender, _name, _age, _email, block.timestamp);
    }

    /**
     * @dev Allows a registered user to update their profile information.
     * @param _newName The new name for the user.
     * @param _newAge The new age for the user.
     * @param _newEmail The new email for the user.
     */
    function updateProfile(string calldata _newName, uint _newAge, string calldata _newEmail) external {
        // @dev Ensure the user is registered before allowing updates.
        require(isRegistered[msg.sender], "You are not registered. Please register first.");
        require(bytes(_newName).length > 0, "Name cannot be empty.");
        require(bytes(_newEmail).length > 0, "Email cannot be empty.");
        require(_newAge > 0, "Age must be positive.");

        users[msg.sender].name = _newName;
        users[msg.sender].age = _newAge;
        users[msg.sender].email = _newEmail;

        emit ProfileUpdated(msg.sender, _newName, _newAge, _newEmail);
    }

    /**
     * @dev Fetches the profile information for the calling address.
     * @return name The name of the user.
     * @return age The age of the user.
     * @return email The email of the user.
     * @return registrationTimestamp The timestamp when the user registered.
     */
    function getProfile() public view returns (string memory name, uint age, string memory email, uint registrationTimestamp) {
        // @dev Ensure the user is registered before fetching their profile.
        require(isRegistered[msg.sender], "You are not registered.");

        User storage user = users[msg.sender];
        return (user.name, user.age, user.email, user.registrationTimestamp);
    }

    /**
     * @dev Fetches the profile information for any specified address.
     * @param _userAddress The address whose profile is to be fetched.
     * @return name The name of the user.
     * @return age The age of the user.
     * @return email The email of the user.
     * @return registrationTimestamp The timestamp when the user registered.
     */
    function getProfileByAddress(address _userAddress) public view returns (string memory name, uint age, string memory email, uint registrationTimestamp) {
        // @dev Ensure the user is registered before fetching their profile.
        require(isRegistered[_userAddress], "User not registered.");

        User storage user = users[_userAddress];
        return (user.name, user.age, user.email, user.registrationTimestamp);
    }
}