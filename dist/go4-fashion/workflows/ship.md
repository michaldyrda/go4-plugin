# Workflow: Shipping

Rate a shipment or track a package via UPS.

## Detect intent

- If the input looks like a tracking number (starts with `1Z`): go to **Track**.
- If it contains a country/weight/destination: go to **Rate**.
- If unclear, ask the manager.

## Rate a shipment

Collect (or extract from arguments):
- **Destination**: postal code + country code (e.g., `75001 FR`)
- **Weight**: in kg
- **Dimensions** (optional): length × width × height in cm

Call `ups_rate_shipment` with:
- `to_postal_code`, `to_country`, `weight_kg`
- Optional: `length_cm`, `width_cm`, `height_cm`, `include_transit_time: true`

The sender defaults to the brand's registered address.

Present available services with prices and delivery estimates in a clear table.

## Track a shipment

Call `ups_track_shipment` with the `tracking_number`.

Show:
- Current status
- Latest events (location, time)
- Estimated delivery date
