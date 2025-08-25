# Independent Bookstore Network & Inventory Sharing System

A decentralized system built on Stacks blockchain using Clarity smart contracts to facilitate collaboration between independent bookstores.

## System Overview

This system enables independent bookstores to:
- Share and transfer book inventory between stores
- Coordinate customer special orders across the network
- Organize and promote author events collaboratively
- Manage community reading programs
- Promote local literature and cultural events

## Smart Contracts

### 1. Bookstore Registry (`bookstore-registry.clar`)
- Register and manage bookstore profiles
- Track store locations, specialties, and contact information
- Maintain store reputation and verification status

### 2. Inventory Manager (`inventory-manager.clar`)
- Track book inventory across all network stores
- Handle inventory sharing requests and transfers
- Manage book metadata (ISBN, title, author, genre, etc.)

### 3. Order Coordinator (`order-coordinator.clar`)
- Process customer special orders
- Route orders to appropriate stores in the network
- Track order fulfillment and customer satisfaction

### 4. Event Manager (`event-manager.clar`)
- Create and manage author events
- Coordinate cross-store promotional activities
- Handle event RSVPs and capacity management

### 5. Community Programs (`community-programs.clar`)
- Manage reading programs and book clubs
- Track participant progress and achievements
- Coordinate community literature initiatives

## Key Features

- **Decentralized Governance**: No single point of control
- **Transparent Operations**: All transactions recorded on blockchain
- **Reputation System**: Build trust through verified transactions
- **Cross-Store Collaboration**: Seamless inventory and event sharing
- **Community Focus**: Tools for local literature promotion

## Getting Started

1. Install dependencies: `npm install`
2. Run tests: `npm test`
3. Deploy contracts using Clarinet
4. Register your bookstore in the network

## Testing

The system includes comprehensive tests using Vitest to ensure contract reliability and security.

## Architecture

The contracts are designed to work independently without cross-contract calls, ensuring maximum security and simplicity. Each contract manages its own domain while providing interfaces for external integration.
