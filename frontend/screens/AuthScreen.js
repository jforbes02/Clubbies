import React, { useState } from 'react';
import { View, Text, TextInput, TouchableOpacity, StyleSheet, KeyboardAvoidingView, Platform, Alert, ActivityIndicator } from 'react-native';
import { useAuth } from '../context/AuthContext';

export default function AuthScreen({ navigation }) {
    const [isLogin, setIsLogin] = useState(true);
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [confirmPassword, setConfirmPassword] = useState('');
    const [username, setUsername] = useState('');
    const [age, setAge] = useState('');

    const { login, register, isLoading } = useAuth();

    const validateForm = () => {
        if (!email.trim()) {
            Alert.alert('Error', 'Email is required');
            return false;
        }
        if (!password.trim()) {
            Alert.alert('Error', 'Password is required');
            return false;
        }
        if (!isLogin) {
            if (!username.trim()) {
                Alert.alert('Error', 'Username is required');
                return false;
            }
            if (!age.trim() || parseInt(age) < 16) {
                Alert.alert('Error', 'You must be at least 16 years old');
                return false;
            }
            if (password !== confirmPassword) {
                Alert.alert('Error', 'Passwords do not match');
                return false;
            }
            if (password.length < 6) {
                Alert.alert('Error', 'Password must be at least 6 characters long');
                return false;
            }
        }
        return true;
    };

    const handleSubmit = async () => {
        if (!validateForm()) return;

        try {
            let result;
            if (isLogin) {
                result = await login(email.trim(), password);
            } else {
                result = await register({
                    username: username.trim(),
                    email: email.trim(),
                    password: password,
                    age: parseInt(age)
                });
            }

            if (result.success) {
                navigation.replace('Main');
            } else {
                Alert.alert('Error', result.error || 'Something went wrong');
            }
        } catch (error) {
            Alert.alert('Error', 'Network error. Please try again.');
        }
    };



    return (
        <KeyboardAvoidingView
            style={styles.container}
            behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
        >
            <View style={styles.content}>
                <Text style={styles.title}>Clubbies</Text>
                <Text style={styles.subtitle}>
                    {isLogin ? 'Welcome back!' : 'Join the nightlife community'}
                </Text>

                <View style={styles.form}>
                    {!isLogin && (
                        <TextInput
                            style={styles.input}
                            placeholder="Username"
                            placeholderTextColor="#666"
                            value={username}
                            onChangeText={setUsername}
                            autoCapitalize="none"
                        />
                    )}

                    <TextInput
                        style={styles.input}
                        placeholder="Email"
                        placeholderTextColor="#666"
                        value={email}
                        onChangeText={setEmail}
                        keyboardType="email-address"
                        autoCapitalize="none"
                    />

                    <TextInput
                        style={styles.input}
                        placeholder="Password"
                        placeholderTextColor="#666"
                        value={password}
                        onChangeText={setPassword}
                        secureTextEntry
                    />

                    {!isLogin && (
                        <TextInput
                            style={styles.input}
                            placeholder="Confirm Password"
                            placeholderTextColor="#666"
                            value={confirmPassword}
                            onChangeText={setConfirmPassword}
                            secureTextEntry
                        />
                    )}

                    {!isLogin && (
                        <TextInput
                            style={styles.input}
                            placeholder="Age"
                            placeholderTextColor="#666"
                            value={age}
                            onChangeText={setAge}
                            keyboardType="numeric"
                        />
                    )}

                    <TouchableOpacity
                        style={[styles.submitButton, isLoading && styles.submitButtonDisabled]}
                        onPress={handleSubmit}
                        disabled={isLoading}
                    >
                        {isLoading ? (
                            <ActivityIndicator color="#fff" />
                        ) : (
                            <Text style={styles.submitButtonText}>
                                {isLogin ? 'Sign In' : 'Sign Up'}
                            </Text>
                        )}
                    </TouchableOpacity>

                    <TouchableOpacity
                        style={styles.switchButton}
                        onPress={() => setIsLogin(!isLogin)}
                    >
                        <Text style={styles.switchButtonText}>
                            {isLogin
                                ? "Don't have an account? Sign up"
                                : "Already have an account? Sign in"
                            }
                        </Text>
                    </TouchableOpacity>

                    <TouchableOpacity
                        style={styles.testButton}
                        onPress={handleTestAPI}
                    >
                        <Text style={styles.testButtonText}>🧪 Test API Connection</Text>
                    </TouchableOpacity>
                </View>
            </View>
        </KeyboardAvoidingView>
    );
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: '#000',
    },
    content: {
        flex: 1,
        justifyContent: 'center',
        padding: 20,
    },
    title: {
        fontSize: 48,
        fontWeight: 'bold',
        color: '#ff6b6b',
        textAlign: 'center',
        marginBottom: 8,
    },
    subtitle: {
        fontSize: 16,
        color: '#ccc',
        textAlign: 'center',
        marginBottom: 40,
    },
    form: {
        width: '100%',
    },
    input: {
        backgroundColor: '#1a1a1a',
        borderRadius: 8,
        padding: 16,
        marginBottom: 16,
        color: '#fff',
        fontSize: 16,
        borderWidth: 1,
        borderColor: '#333',
    },
    submitButton: {
        backgroundColor: '#ff6b6b',
        borderRadius: 8,
        padding: 16,
        alignItems: 'center',
        marginTop: 16,
    },
    submitButtonDisabled: {
        backgroundColor: '#666',
    },
    submitButtonText: {
        color: '#fff',
        fontSize: 18,
        fontWeight: 'bold',
    },
    switchButton: {
        marginTop: 24,
        alignItems: 'center',
    },
    switchButtonText: {
        color: '#ff6b6b',
        fontSize: 14,
    },
});