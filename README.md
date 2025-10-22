# Garbage Collection Scheduling System

A smart contract system for sanitation departments to manage collection routes, recycling programs, and service announcements efficiently.

## Overview

The Garbage Collection Scheduling System provides sanitation departments with tools to optimize garbage collection routes, manage recycling programs, schedule pickups, and communicate service changes to residents. This blockchain-based solution ensures transparency, efficiency, and accountability in waste management operations.

## Real-World Application

Sanitation departments face complex challenges in managing waste collection:
- Optimizing collection routes for fuel and time efficiency
- Coordinating regular and special collection schedules
- Managing different waste streams (garbage, recycling, yard waste)
- Communicating schedule changes to residents
- Tracking service coverage and missed collections
- Managing seasonal variations and special events

This smart contract system digitizes these operations, providing real-time tracking, automated notifications, and transparent service records.

## Core Features

### Route Management
- Define collection routes with multiple stops
- Assign vehicles and crews to routes
- Track route optimization and efficiency metrics
- Update route configurations dynamically
- Record route completion and timing

### Collection Scheduling
- Schedule regular weekly/bi-weekly collections
- Plan special collection events (bulk waste, electronics)
- Manage holiday schedule modifications
- Coordinate multiple waste stream pickups
- Track schedule adherence

### Recycling Program Management
- Register different recycling program types
- Track participation and collection volumes
- Manage program enrollment by address/zone
- Record recycling statistics for reporting
- Support multi-stream recycling

### Service Announcements
- Post service alerts and notifications
- Communicate schedule changes
- Announce special collection events
- Track announcement delivery status
- Maintain historical communication records

### Address & Zone Management
- Register service addresses with zones
- Associate addresses with collection routes
- Track service status per address
- Manage zone-based scheduling
- Support geographic service organization

### Collection Verification
- Record completed collections with timestamps
- Track missed pickups and reasons
- Verify service delivery
- Generate completion reports
- Support accountability and quality control

## Technical Details

### Smart Contract: waste-collection-scheduler.clar

The contract implements the following key functions:

**Route Management:**
- `create-route` - Define new collection routes
- `update-route-status` - Modify route active status
- `assign-vehicle-to-route` - Assign vehicles/crews
- `complete-route` - Record route completion
- `get-route-info` - Query route details

**Schedule Management:**
- `schedule-collection` - Create collection schedules
- `update-collection-status` - Modify schedule status
- `record-collection` - Log completed collections
- `get-schedule-info` - Retrieve schedule data

**Recycling Program Management:**
- `create-recycling-program` - Define recycling programs
- `enroll-address-in-program` - Register participants
- `record-recycling-collection` - Track recycling pickups
- `get-program-info` - Query program details

**Service Communication:**
- `post-service-announcement` - Create announcements
- `get-announcement` - Retrieve announcements
- `get-active-announcements` - List current alerts

**Address Management:**
- `register-service-address` - Add service locations
- `update-address-status` - Modify service status
- `get-address-info` - Query address details

**Administrative Functions:**
- Role-based access control for sanitation administrators
- Query functions for reporting and analytics
- Validation and conflict prevention

## Data Structures

The contract maintains several key data maps:
- **routes** - Collection route definitions and configurations
- **schedules** - Regular and special collection schedules
- **addresses** - Service addresses with zones and status
- **recycling-programs** - Program definitions and enrollment
- **collections** - Historical collection records
- **announcements** - Service notifications and alerts

## Use Cases

1. **Daily Operations**: Route optimization and crew assignments
2. **Schedule Planning**: Weekly/monthly collection calendars
3. **Resident Services**: Real-time service status and notifications
4. **Recycling Management**: Program enrollment and tracking
5. **Performance Monitoring**: Collection metrics and KPIs
6. **Special Events**: Holiday schedules and bulk waste days
7. **Accountability**: Missed pickup tracking and resolution

## Security & Governance

- Administrator-only functions for route and schedule management
- Immutable collection records for accountability
- Validation to prevent scheduling conflicts
- Transparent service delivery tracking
- Audit trail for all operations

## Getting Started

### Prerequisites
- Clarinet CLI installed
- Basic understanding of Clarity smart contracts
- Node.js for running tests

### Installation

```bash
# Clone the repository
git clone <repository-url>

# Navigate to project directory
cd garbage-collection-scheduling

# Run contract checks
clarinet check

# Run tests
npm test
```

### Usage Example

```clarity
;; Create a collection route
(contract-call? .waste-collection-scheduler create-route 
  "North District Route A" 
  u50)

;; Register a service address
(contract-call? .waste-collection-scheduler register-service-address 
  "123 Main Street" 
  u1 
  u1)

;; Schedule a collection
(contract-call? .waste-collection-scheduler schedule-collection 
  u1 
  u1 
  u1730476800 
  "regular")

;; Post service announcement
(contract-call? .waste-collection-scheduler post-service-announcement 
  "Holiday Schedule Change" 
  "No collection on Thursday - service moved to Friday" 
  u1730908800)
```

## Development

### Project Structure
```
garbage-collection-scheduling/
├── contracts/
│   └── waste-collection-scheduler.clar
├── tests/
│   └── waste-collection-scheduler.test.ts
├── settings/
│   ├── Devnet.toml
│   ├── Testnet.toml
│   └── Mainnet.toml
├── Clarinet.toml
└── README.md
```

### Testing

Run the test suite to verify contract functionality:

```bash
clarinet test
```

### Deployment

Configure deployment settings in the appropriate network file and deploy using Clarinet.

## Benefits

- **Efficiency**: Optimized routes reduce fuel costs and time
- **Transparency**: Residents can track service status in real-time
- **Accountability**: Immutable records of collections and service delivery
- **Reliability**: Automated scheduling prevents missed services
- **Sustainability**: Enhanced recycling program management
- **Communication**: Timely notifications of schedule changes

## Future Enhancements

- Integration with GPS tracking for real-time vehicle location
- Mobile app for residents to report missed collections
- AI-powered route optimization based on traffic and weather
- Automated billing integration
- Weight-based collection tracking for waste reduction metrics
- Community recycling leaderboards and incentives

## License

MIT License

## Contributing

Contributions are welcome! Please submit pull requests or open issues for bugs and feature requests.

## Support

For questions or issues, please open a GitHub issue or contact the development team.

# garuage collection scheduling

Garbage collection route optimization and recycling program management

## Smart Contract: waste-collection-scheduler

Blockchain-based system on Stacks.
