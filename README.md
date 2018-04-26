# Linode DNS Api for Ruby

## Set Linode Api key
```
LinodeDnsApi::Domain.set_api_key("your_linode_api_key")
```

## Get List of Domains
```
domains = LinodeDnsApi::Domain.list
```
This method return `Array<String>`

## Get one Domain:
```
domain = LinodeDnsApi::Domain.get("4talent.cl")
```
This method return a Object Domain

## Add new Resource to Domain:
```
domain = LinodeDnsApi::Domain.get("4talent.cl")
domain.resources.new("subdomain", "198.58.119.200")
```

## Remove Resource:
```
domain = LinodeDnsApi::Domain.get("4talent.cl")
domain.resources.detect { |r| r.name == "subdomain"}.delete
```
#### OR
```
domain = LinodeDnsApi::Domain.get("subdomain.4talent.cl")
domain.resources.delete("subdomain")
```
