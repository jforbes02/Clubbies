import React from 'react';
import { View, Text, StyleSheet, FlatList, SafeAreaView } from 'react-native';

const mockNotifications = [
    {
        id: '1',
        title: 'New Event at Club XYZ',
        message: 'Join us for an amazing night of music and dancing!',
        time: '2 hours ago',
        read: false,
    },
    {
        id: '2',
        title: 'Venue Booking Confirmed',
        message: 'Your booking for Saturday night has been confirmed.',
        time: '5 hours ago',
        read: true,
    },
    {
        id: '3',
        title: 'Friend Request',
        message: 'Alex wants to connect with you on Clubbies.',
        time: '1 day ago',
        read: false,
    },
    {
        id: '4',
        title: 'Special Offer',
        message: 'Get 20% off your next venue booking this weekend!',
        time: '2 days ago',
        read: true,
    },
];

const NotificationItem = ({ item }) => (
    <View style={[styles.notificationCard, !item.read && styles.unreadCard]}>
        <View style={styles.notificationContent}>
            <Text style={styles.notificationTitle}>{item.title}</Text>
            <Text style={styles.notificationMessage}>{item.message}</Text>
            <Text style={styles.notificationTime}>{item.time}</Text>
        </View>
        {!item.read && <View style={styles.unreadDot} />}
    </View>
);

export default function NotiScreen() {
    return (
        <SafeAreaView style={styles.container}>
            <Text style={styles.title}>Notifications</Text>
            <FlatList
                data={mockNotifications}
                keyExtractor={(item) => item.id}
                renderItem={({ item }) => <NotificationItem item={item} />}
                showsVerticalScrollIndicator={false}
                contentContainerStyle={styles.listContainer}
            />
        </SafeAreaView>
    );
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: '#000',
        paddingHorizontal: 20,
        paddingTop: 20,
    },
    title: {
        fontSize: 28,
        fontWeight: 'bold',
        color: '#ff6b6b',
        marginBottom: 20,
        textAlign: 'center',
    },
    listContainer: {
        paddingBottom: 20,
    },
    notificationCard: {
        backgroundColor: '#1a1a1a',
        borderRadius: 12,
        padding: 16,
        marginBottom: 12,
        borderLeftWidth: 4,
        borderLeftColor: '#333',
        flexDirection: 'row',
        alignItems: 'flex-start',
        shadowColor: '#000',
        shadowOffset: {
            width: 0,
            height: 2,
        },
        shadowOpacity: 0.25,
        shadowRadius: 3.84,
        elevation: 5,
    },
    unreadCard: {
        borderLeftColor: '#ff6b6b',
        backgroundColor: '#2a1a1a',
    },
    notificationContent: {
        flex: 1,
    },
    notificationTitle: {
        fontSize: 16,
        fontWeight: 'bold',
        color: '#fff',
        marginBottom: 6,
    },
    notificationMessage: {
        fontSize: 14,
        color: '#ccc',
        lineHeight: 20,
        marginBottom: 8,
    },
    notificationTime: {
        fontSize: 12,
        color: '#888',
    },
    unreadDot: {
        width: 8,
        height: 8,
        borderRadius: 4,
        backgroundColor: '#ff6b6b',
        marginTop: 6,
        marginLeft: 10,
    },
});