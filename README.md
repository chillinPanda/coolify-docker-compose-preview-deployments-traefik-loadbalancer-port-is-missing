# Intro

Demo for reproducing the issue [#2184](https://github.com/coollabsio/coolify/issues/2184) where Preview Deployments are missing the traefik loadbalancer port label when using docker-compose.

# Example

The "normal" generated docker-compose.yaml contains:

```yaml
- 'traefik.http.routers.https-0-uuid-prisma-studio.rule=Host(`prisma-studio.example.com`) && PathPrefix(`/`)'
- traefik.http.services.http-0-uuid-prisma-studio.loadbalancer.server.port=5555
- traefik.http.services.https-0-uuid-prisma-studio.loadbalancer.server.port=5555
```

The "pr preview" docker-compose-pr-1.yaml is missing the two port lines.

# Reproduction

1. Fork this repo into your account
2. Add your fork into your GitHub App
   * In Coolify -> Sources -> your GitHub App -> on the top: "Update Repositories"
3. Create a new project / resource using your fork
   * Using main branch
   * Using docker-compose.yaml
4. In the domains section map the nginx to port 1234, e.g. https://reproduction.myhost.com:1234
5. Deploy the application
6. Verify that it is working

# Looking at the code

## "Normal Application"

For the "normal" application, the configured port from the "Domains" settings section is used and added as a label:

[Link](https://github.com/coollabsio/coolify/blob/6cc338b7a66ca68685da52fe28d6cd8b07aa628c/bootstrap/helpers/docker.php#L439)

```php
if ($schema === 'https') {
    // Set labels for https
    $labels->push("traefik.http.routers.{$https_label}.rule=Host(`{$host}`) && PathPrefix(`{$path}`)");
    $labels->push("traefik.http.routers.{$https_label}.entryPoints=https");
    if ($port) {
        $labels->push("traefik.http.routers.{$https_label}.service={$https_label}");
        $labels->push("traefik.http.services.{$https_label}.loadbalancer.server.port=$port");
    }
```

## Preview Deployment

I see that the domain is replaced with the preview domain template, but I cannot find a port section.

[Code Link](https://github.com/coollabsio/coolify/blob/6cc338b7a66ca68685da52fe28d6cd8b07aa628c/app/Livewire/Project/Application/Previews.php#L97)

```php
$fqdn = generateFqdn($this->application->destination->server, $this->application->uuid);
$url = Url::fromString($fqdn);
$template = $this->application->preview_url_template;
$host = $url->getHost();
$schema = $url->getScheme();
$random = new Cuid2;
$preview_fqdn = str_replace('{{random}}', $random, $template);
$preview_fqdn = str_replace('{{domain}}', $host, $preview_fqdn);
$preview_fqdn = str_replace('{{pr_id}}', $preview->pull_request_id, $preview_fqdn);
$preview_fqdn = "$schema://$preview_fqdn";
$preview->fqdn = $preview_fqdn;
$preview->save();
$this->dispatch('success', 'Domain generated.');
```
