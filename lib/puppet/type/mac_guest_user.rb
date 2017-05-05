Puppet::Type.newtype(:mac_guest_user) do
  @doc = "Makes a user a guest user"

  newparam(:name, :namevar => true)

  ensurable do
          desc "Possible values are *present* and *absent*"

          newvalue(:absent) do
              if @resource.provider.exists?
                  @resource.provider.destroy
              end
          end

          newvalue(:present) do
              unless @resource.provider.exists?
                  @resource.provider.create
              end
          end
      end

end
