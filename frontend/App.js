import React, { useState, useEffect } from 'react';
import {SafeAreaView, Text, ActivityIndicator, StyleSheet} from "react-native";

export default function App() {
    const [message, setMessage] = useState("");
    const [loading, setLoading] = useState(true)

    useEffect(async () => {
        fetch('http://127.0.0.1:8000/health')
            .then(res => res.json())
            .then(data => {
                setMessage(data.message);
                setLoading(false);
            })
            .catch(err => {
                console.error('Error fetching', err);
                setMessage('Could not to backend');
                setLoading(false);
            });
    }, []);

    return (
        <SafeAreaView style={styles.container}>
            {loading
            ? <ActivityIndicator size='large' />
            : <Text style={styles.text}>{message}</Text>}
        </SafeAreaView>
    );
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
    },
    text: {
        fontSize: 20,
    }
});