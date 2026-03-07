import { supabase } from '@/integrations/supabase/client';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { toast } from 'sonner';

export interface CourierSettings {
  id: string;
  provider: string;
  enabled: boolean;
  api_base_url: string | null;
  api_key: string | null;
  api_secret: string | null;
  merchant_id: string | null;
  pickup_address: string | null;
  pickup_phone: string | null;
  default_weight: number;
  cod_enabled: boolean;
  show_tracking_to_customer: boolean;
  created_at: string;
  updated_at: string;
}

export const useCourierSettings = (provider: string) => {
  return useQuery({
    queryKey: ['courier_settings', provider],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('courier_settings')
        .select('*')
        .eq('provider', provider)
        .maybeSingle();
      
      if (error) throw error;
      return data as CourierSettings | null;
    },
  });
};

export const useSaveCourierSettings = () => {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: async (settings: Partial<CourierSettings> & { provider: string }) => {
      const { data: existing } = await supabase
        .from('courier_settings')
        .select('id')
        .eq('provider', settings.provider)
        .maybeSingle();

      if (existing) {
        // Update existing
        const { data, error } = await supabase
          .from('courier_settings')
          .update(settings)
          .eq('provider', settings.provider)
          .select()
          .single();
        
        if (error) throw error;
        return data;
      } else {
        // Insert new
        const { data, error } = await supabase
          .from('courier_settings')
          .insert(settings)
          .select()
          .single();
        
        if (error) throw error;
        return data;
      }
    },
    onSuccess: (_, variables) => {
      queryClient.invalidateQueries({ queryKey: ['courier_settings', variables.provider] });
      toast.success('Courier settings saved');
    },
    onError: (error) => {
      toast.error('Failed to save settings: ' + error.message);
    },
  });
};

export const useTestCourierConnection = () => {
  return useMutation({
    mutationFn: async (credentials: {
      api_base_url: string;
      api_key: string;
      api_secret: string;
    }) => {
      // Call through Vite dev proxy to bypass CORS
      // The proxy at /api/steadfast/* forwards to https://portal.steadfast.com.bd/api/v1/*
      const res = await fetch('/api/steadfast/get_balance', {
        headers: {
          'Api-Key': credentials.api_key,
          'Secret-Key': credentials.api_secret,
          'Content-Type': 'application/json',
        },
      });

      if (!res.ok) {
        // Try to parse error message from response
        try {
          const errorData = await res.json();
          return { success: false, error: errorData.message || `API returned status ${res.status}` };
        } catch {
          // Steadfast returns HTML error page for invalid credentials
          return { success: false, error: 'Invalid API credentials. Please check your API Key and Secret.' };
        }
      }

      const data = await res.json();
      if (data.status === 200) {
        return { success: true, balance: data.current_balance };
      }
      return { success: false, error: data.message || 'Connection failed' };
    },
  });
};

export const useCreateCourierParcel = () => {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: async (payload: {
      order_id: string;
      recipient_name: string;
      recipient_phone: string;
      recipient_address: string;
      recipient_city: string;
      cod_amount: number;
      invoice: string;
      note?: string;
    }) => {
      const { data: { session } } = await supabase.auth.getSession();
      
      const response = await supabase.functions.invoke('steadfast-courier/create-parcel', {
        body: payload,
        headers: {
          Authorization: `Bearer ${session?.access_token}`,
        },
      });

      if (response.error) throw new Error(response.error.message);
      if (!response.data.success) throw new Error(response.data.error);
      return response.data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['orders'] });
      toast.success('Parcel created successfully');
    },
    onError: (error) => {
      toast.error('Failed to create parcel: ' + error.message);
    },
  });
};

export const useTrackCourierStatus = () => {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: async (payload: { consignment_id: string; order_id: string }) => {
      const { data: { session } } = await supabase.auth.getSession();
      
      const response = await supabase.functions.invoke('steadfast-courier/track-status', {
        body: payload,
        headers: {
          Authorization: `Bearer ${session?.access_token}`,
        },
      });

      if (response.error) throw new Error(response.error.message);
      if (!response.data.success) throw new Error(response.data.error);
      return response.data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['orders'] });
      toast.success('Tracking status updated');
    },
    onError: (error) => {
      toast.error('Failed to track status: ' + error.message);
    },
  });
};
